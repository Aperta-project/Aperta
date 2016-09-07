# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'paper_task_finders'

##
# This class represents the paper in the system.
class Paper < ActiveRecord::Base
  include EventStream::Notifiable
  include PaperTaskFinders
  include AASM
  include ActionView::Helpers::SanitizeHelper
  include PgSearch
  include Assignable::Model
  include Snapshottable

  self.snapshottable = true

  belongs_to :journal, inverse_of: :papers
  belongs_to :striking_image, polymorphic: true

  # Attachment-related things
  has_many :figures, as: :owner, dependent: :destroy
  has_many :question_attachments, dependent: :destroy
  has_many :supporting_information_files, dependent: :destroy
  has_many :adhoc_attachments, dependent: :destroy
  has_one :file, as: :owner, dependent: :destroy,
    class_name: 'ManuscriptAttachment'

  # Everything else
  has_many :versioned_texts, dependent: :destroy
  has_many :tables, dependent: :destroy
  has_many :bibitems, dependent: :destroy
  has_many :billing_logs, dependent: :destroy, foreign_key: 'documentid'
  has_many :paper_roles, dependent: :destroy
  has_many :users, -> { uniq }, through: :paper_roles
  has_many :old_assigned_users, -> { uniq }, through: :paper_roles, source: :user
  has_many :assigned_users, -> { uniq }, through: :assignments, source: :user
  has_many :phases, -> { order 'phases.position ASC' },
           dependent: :destroy,
           inverse_of: :paper
  has_many :tasks, inverse_of: :paper
  has_many :comments, through: :tasks
  has_many :comment_looks, through: :comments
  has_many :journal_roles, through: :journal
  has_many :activities, as: :subject
  has_many :decisions, dependent: :destroy
  has_many :discussion_topics, inverse_of: :paper, dependent: :destroy
  has_many :snapshots, dependent: :destroy
  has_many :notifications, inverse_of: :paper
  has_many :nested_question_answers
  has_many :assignments, as: :assigned_to
  has_many :roles, through: :assignments
  has_many :related_articles, dependent: :destroy
  has_many :withdrawals, dependent: :destroy

  has_many :authors,
           -> { order 'author_list_items.position ASC' },
           through: :author_list_items,
           source_type: "Author"
  has_many :group_authors,
           -> { order 'author_list_items.position ASC' },
           through: :author_list_items,
           source_type: "GroupAuthor",
           source: :author
  has_many :author_list_items, -> { order 'position ASC' }, dependent: :destroy

  validates :paper_type, presence: true
  validates :journal, presence: true
  validates :title, presence: true

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # we will want an index on this at some point, maybe not this point
  # https://github.com/Casecommons/pg_search/wiki/Building-indexes
  pg_search_scope :pg_title_search,
                  against: :title,
                  using: {
                    tsearch: {dictionary: "english"} # stems
                  }

  delegate :major_version, :minor_version,
           to: :latest_submitted_version, allow_nil: true
  delegate :figureful_text,
           to: :latest_version, allow_nil: true

  def manuscript_id
    journal_prefix_and_number = doi.split('/').last.split('.') if doi
    journal_prefix_and_number.try(:shift) # Remove 'journal' text
    journal_prefix_and_number.try(:join, '.')
  end

  after_create :assign_doi!
  after_create :create_versioned_texts
  after_commit :state_transition_notifications

  aasm column: :publishing_state do
    state :unsubmitted, initial: true # currently being authored
    state :initially_submitted, before_enter: :new_draft_decision!
    state :invited_for_full_submission
    state :submitted, before_enter: :new_draft_decision!
    state :checking # small change that does not require resubmission, as in a tech check
    state :in_revision # has revised decision and requires resubmission
    state :accepted
    state :rejected
    state :published
    state :withdrawn

    after_all_transitions :set_state_updated!

    event(:initial_submit) do
      transitions from: :unsubmitted,
                  to: :initially_submitted,
                  after: [:assign_submitting_user!,
                          :set_submitted_at!,
                          :set_first_submitted_at!,
                          :prevent_edits!,
                          :new_minor_version!]
    end

    event(:submit) do
      # Major version numbers represent the number of times
      # the manuscript has been revised. Initial submissions
      # and first full submissions are not revisions, and
      # so they do not increment that number.
      transitions from: [:in_revision],
                  to: :submitted,
                  guards: :metadata_tasks_completed?,
                  after: [:assign_submitting_user!,
                          :set_submitted_at!,
                          :set_first_submitted_at!,
                          :prevent_edits!,
                          :new_major_version!]
      transitions from: [:unsubmitted,
                         :invited_for_full_submission],
                  to: :submitted,
                  guards: :metadata_tasks_completed?,
                  after: [:assign_submitting_user!,
                          :set_submitted_at!,
                          :set_first_submitted_at!,
                          :prevent_edits!,
                          :new_minor_version!]
    end

    event(:invite_full_submission) do
      transitions from: :initially_submitted,
                  to: :invited_for_full_submission,
                  after: [:allow_edits!, :new_draft!]
    end

    event(:minor_check) do
      transitions from: :submitted,
                  to: :checking,
                  after: [:allow_edits!, :new_draft!]
    end

    event(:submit_minor_check) do
      transitions from: :checking,
                  to: :submitted,
                  after: [:assign_submitting_user!,
                          :prevent_edits!,
                          :new_minor_version!]
    end

    event(:minor_revision) do
      transitions from: :submitted,
                  to: :in_revision,
                  after: [:allow_edits!, :new_draft!]
    end

    event(:major_revision) do
      transitions from: :submitted,
                  to: :in_revision,
                  after: [:allow_edits!, :new_draft!]
    end

    event(:accept) do
      transitions from: :submitted,
                  to: :accepted,
                  after: [:set_accepted_at!]
    end

    event(:reject) do
      transitions from: [:initially_submitted, :submitted],
                  to: :rejected
      before do
        update(active: false)
      end
    end

    event(:publish) do
      transitions from: :submitted,
                  to: :published,
                  after: [:set_published_at!]
    end

    event(:withdraw) do
      transitions to: :withdrawn,
                  after: :prevent_edits!
      before do |withdrawal_reason, withdrawn_by_user|
        withdrawal_reason || fail(ArgumentError, "withdrawal_reason must be provided")
        withdrawn_by_user || fail(ArgumentError, "withdrawn_by_user must be provided")
        update(active: false)
        withdrawals.create!(
          previous_publishing_state: publishing_state,
          previous_editable: editable,
          reason: withdrawal_reason,
          withdrawn_by_user_id: withdrawn_by_user.id
        )
      end
    end

    event(:reactivate) do
      # AASM doesn't currently allow transitions to dynamic states, so this iterator
      # explicitly defines each transition
      Paper.aasm.states.map(&:name).each do |state|
        transitions from: :withdrawn, to: state, after: :set_editable!, if: Proc.new { previous_state_is?(state) }
      end
      before do
        update(active: true)
      end
    end

    event(:rescind_initial_decision) do
      transitions to: :initially_submitted,
                  guard: -> { last_completed_decision.initial },
                  from: [:rejected,
                         :invited_for_full_submission],
                  after: [:new_draft!,
                          :new_minor_version!]
    end

    event(:rescind_decision) do
      transitions to: :submitted,
                  guard: -> { !last_completed_decision.initial },
                  from: [:rejected, :accepted,
                         :in_revision],
                  after: [:new_draft!,
                          :new_minor_version!]
    end
  end

  # All known paper states
  STATES = aasm.states.map(&:name)
  # States which should generally be editable by the creator
  EDITABLE_STATES = [:unsubmitted, :in_revision, :invited_for_full_submission,
                     :checking]
  # States which should generally NOT be editable by the creator
  UNEDITABLE_STATES = [:initially_submitted, :submitted, :accepted, :rejected,
                       :published, :withdrawn]
  # States that represent the creator has submitted their paper
  SUBMITTED_STATES = [:initially_submitted, :submitted]
  # States that represent when a paper can be reviewed by a Reviewer
  REVIEWABLE_STATES = EDITABLE_STATES + SUBMITTED_STATES

  TERMINAL_STATES = [:accepted, :rejected]

  def snapshottable_things
    [].concat(tasks)
      .concat(figures)
      .concat(supporting_information_files)
      .concat(adhoc_attachments)
      .concat(question_attachments)
      .select(&:snapshottable?)
  end

  def users_with_role(role)
    return User.none unless role
    User.joins(:assignments).where(
      'assignments.role_id' => role.id,
      'assignments.assigned_to_id' => id,
      'assignments.assigned_to_type' => 'Paper')
  end

  def inactive?
    !active?
  end

  def previous_state_is?(event)
    withdrawals.last[:previous_publishing_state] == event.to_s
  end

  def awaiting_decision?
    SUBMITTED_STATES.include? publishing_state.to_sym
  end

  def body
    @new_body || latest_version.try(:text)
  end

  def body=(new_body)
    # We have an issue here. the first version is created on
    # after_create (because it needs the paper_id). But if this is
    # called before creation, it will fail. Get around this by storing
    # the text in @new_body if there is no latest version
    if latest_version.nil?
      @new_body = new_body
    else
      draft.update(original_text: new_body)
      notify(action: "updated") unless changed?
    end
  end

  # Returns the corresponding authors. When there are no authors
  # marked as corresponding then it defaults to the creator.
  def corresponding_authors
    corresponding_authors = authors.select { |au| au.corresponding? }
    corresponding_authors << creator if corresponding_authors.empty?
    corresponding_authors.compact
  end

  # Returns the corresponding author emails. When there are no authors
  # marked as corresponding then it defaults to the creator's email address.
  def corresponding_author_emails
    corresponding_authors.map(&:email)
  end

  # Downloads the manuscript from the given URL.
  def download_manuscript!(url, uploaded_by:)
    attachment = file || create_file
    attachment.download!(url, uploaded_by: uploaded_by)
  end

  # Public: Find `Role`s for the given user on this paper.
  #
  # Examples
  #
  #   Paper.roles_for(user: User.first)
  #   Paper.roles_for(user: User.first, roles: [Role.first])
  #
  # Returns an Array with <tt>Role</tt>s.
  def roles_for(user:, roles: nil)
    role_ids = roles.map(&:id) if roles
    # Do not hit the database again if the roles are eager-loaded
    if self.roles.loaded?
      retval = assignments.select { |a| a.user_id == user.id }.map(&:role)
      retval = retval.select { |r| role_ids.member?(r.id) } if role_ids
      return retval
    end
    args = { assignments: { user_id: user } }
    args[:assignments][:role_id] = role_ids if role_ids
    self.roles.where(args).to_a
  end

  def role_descriptions_for(user:)
    roles_for(user: user).map do |role|
      if role == journal.creator_role
        'My Paper'
      else
        role.name
      end
    end
  end

  def tasks_for_type(klass_name)
    tasks.where(type: klass_name)
  end

  # Public: Returns the paper title if it's present, otherwise short title is shown.
  #
  # Examples
  #
  #   display_title
  #   # => "Studies on the effect of humans living with other humans"
  #   # or
  #   # => "some-short-title"
  #
  # Returns a String.
  def display_title(sanitized: true)
    sanitized ? strip_tags(title) : title.html_safe
  end

  # Public: Returns one of the admins from the paper.
  #
  # Examples
  #
  #   admin
  #   # => <#124: User>
  #
  # Returns a User object.
  def admin
    admins.first
  end

  # Public: Returns the academic editors assigned to this paper
  #
  # Examples
  #
  #   paper.academic_editors
  #   # => [<#124: User>, <#125: User>]
  #
  # Returns a collection of User objects
  def academic_editors
    users_with_role(journal.academic_editor_role)
  end

  def cover_editors
    users_with_role(journal.cover_editor_role)
  end

  def handling_editors
    users_with_role(journal.handling_editor_role)
  end

  def reviewers
    users_with_role(journal.reviewer_role)
  end

  def short_title
    answer = answer_for('publishing_related_questions--short_title')
    answer ? answer.value : ''
  end

  def latest_withdrawal
    withdrawals.most_recent
  end

  # Accepts any args the state transition accepts
  def metadata_tasks_completed?(*)
    tasks.metadata.count == tasks.metadata.completed.count
  end

  # Accepts any args the state transition accepts
  def prevent_edits!(*)
    update!(editable: false)
  end

  def allow_edits!
    update!(editable: true)
  end

  def creator
    User.assigned_to(self, role: journal.creator_role).first
  end

  def creator=(user)
    assignments.where(role: journal.creator_role).destroy_all
    assignments.build(role: journal.creator_role,
                      user: user,
                      assigned_to: self)
  end

  def collaborations
    Assignment.where(
      role: [
        journal.creator_role,
        journal.collaborator_role
      ],
      assigned_to: self
    )
  end

  def collaborators
    User.assigned_to(self,
                     role: [journal.creator_role,
                            journal.collaborator_role])
  end

  def add_academic_editor(user)
    assignments
      .where(user: user, role: journal.academic_editor_role)
      .first_or_create!
  end

  def add_collaboration(user)
    assignments
      .where(user: user, role: journal.collaborator_role)
      .first_or_create!
  end

  def remove_collaboration(collaboration)
    if collaboration.is_a?(User)
      collaboration = collaborations.find_by(user: collaboration)
    elsif !collaboration.is_a?(Assignment)
      collaboration = collaborations.find_by(id: collaboration)
    end

    collaboration.destroy if collaboration.role == journal.collaborator_role
    collaboration
  end

  def participations
    Assignment.where(
      role: paper_participation_roles,
      assigned_to: self
    ).includes(:role, :user)
  end

  def participants
    participations.map(&:user).uniq
  end

  def participants_by_role
    group_participants_by_role(participations)
  end

  %w(admins).each do |relation|
    ###
    # :method: <old_roles>
    # Public: Return user records by old_role in the paper.
    #
    # Examples
    #
    #   editors   # => [user1, user2]
    #
    # Returns an Array of User records.
    #
    # Signature
    #
    #   #<old_roles>
    #
    # old_role - A old_role name on the paper
    define_method relation.to_sym do
      old_assigned_users.merge(PaperRole.send(relation))
    end
  end

  # Return the latest version of this paper.
  # This will ALWAYS return a new instance.
  def latest_version
    versioned_texts(true).version_desc.first
  end

  def latest_submitted_version
    versioned_texts.completed.version_desc.first
  end

  def latest_decision_rescinded?
    return false unless last_completed_decision
    last_completed_decision.rescinded
  end

  def new_draft!
    latest_version.new_draft! unless draft
  end

  def new_draft_decision!
    decisions.create unless draft_decision
  end

  def draft
    versioned_texts.drafts.first
  end

  def draft_decision
    decisions.drafts.first
  end

  def last_completed_decision
    decisions.completed.version_asc.last
  end

  def insert_figures!
    latest_version.insert_figures!
    notify
  end

  def answer_for(ident)
    nested_question_answers.includes(:nested_question)
      .find_by(nested_questions: { ident: ident })
  end

  def in_terminal_state?
    TERMINAL_STATES.include? publishing_state.to_sym
  end

  def last_of_task(klass)
    tasks.where(type: klass.to_s).last
  end

  private

  def new_major_version!
    draft.be_major_version!
  end

  def new_minor_version!
    draft.be_minor_version!
  end

  def set_editable!
    update!(editable: withdrawals.last[:previous_editable])
  end

  def set_published_at!
    update!(published_at: Time.current.utc)
  end

  def set_submitted_at!
    update!(submitted_at: Time.current.utc)
  end

  def set_accepted_at!
    update!(accepted_at: Time.current.utc)
  end

  def set_first_submitted_at!
    return if first_submitted_at
    update!(first_submitted_at: Time.current.utc)
  end

  def set_state_updated!
    update!(state_updated_at: Time.current.utc)
    Activity.state_changed! self, to: publishing_state
  end

  def assign_submitting_user!(submitting_user)
    draft.update!(submitting_user: submitting_user)
  end

  def assign_doi!
    self.update!(doi: DoiService.new(journal: journal).next_doi!) if journal
  end

  def create_versioned_texts
    versioned_texts.create! major_version: nil,
                            minor_version: nil,
                            original_text: (@new_body || '')
  end

  def state_changed?
    previous_changes &&
      previous_changes.key?(:publishing_state) &&
      previous_changes[:publishing_state] != publishing_state
  end

  def state_transition_notifications
    return unless state_changed?

    notify action: publishing_state
  end

  def paper_participation_roles
    [
      journal.creator_role,
      journal.collaborator_role,
      journal.reviewer_role,
      journal.academic_editor_role
    ]
  end

  def group_participants_by_role(participations_to_group)
    by_role_hsh = participations_to_group.group_by(&:role)
    by_role_hsh.each_with_object({}) do |(role, participation), hsh|
      hsh[role.name] = participation.map(&:user).uniq
    end
  end
end
