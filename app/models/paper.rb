##
# This class represents the paper in the system.
class Paper < ActiveRecord::Base
  include EventStream::Notifiable
  include PaperTaskFinders
  include AASM
  include ActionView::Helpers::SanitizeHelper
  include PgSearch
  include Assignable::Model
  include ExpiringCacheKey

  belongs_to :journal, inverse_of: :papers
  belongs_to :flow
  belongs_to :striking_image, polymorphic: true

  has_many :figures, dependent: :destroy
  has_many :versioned_texts, dependent: :destroy
  has_many :tables, dependent: :destroy
  has_many :bibitems, dependent: :destroy
  has_many :supporting_information_files, dependent: :destroy
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
  has_many :authors
  has_many :group_authors
  has_many :decisions, -> { order 'revision_number DESC' }, dependent: :destroy
  has_many :discussion_topics, inverse_of: :paper, dependent: :destroy
  has_many :snapshots, dependent: :destroy
  has_many :notifications, inverse_of: :paper
  has_many :nested_question_answers
  has_many :assignments, as: :assigned_to
  has_many :roles, through: :assignments

  serialize :withdrawals, ArrayHashSerializer

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

  delegate :major_version, :minor_version, :figureful_text,
           to: :latest_version, allow_nil: true

  def manuscript_id
    doi.split('/').last if doi
  end

  after_create :assign_doi!
  after_create :create_versioned_texts
  after_commit :state_transition_notifications

  aasm column: :publishing_state do
    state :unsubmitted, initial: true # currently being authored
    state :initially_submitted
    state :invited_for_full_submission
    state :submitted
    state :checking # small change that does not require resubmission, as in a tech check
    state :in_revision # has revised decision and requires resubmission
    state :accepted
    state :rejected
    state :published
    state :withdrawn

    # TODO: When we upgrade aasm, use new after_all_tranisitions to ensure that
    # expire_permissions_cache is run after all transitions.
    #
    # In the meantime, be sure to add expire_permissions_cache to your after
    # list if you add a new transition.
    event(:initial_submit) do
      transitions from: :unsubmitted,
                  to: :initially_submitted,
                  after: [:set_submitted_at!,
                          :set_first_submitted_at!,
                          :prevent_edits!,
                          :expire_permissions_cache]
    end

    event(:submit) do
      transitions from: [:unsubmitted,
                         :initially_submitted,
                         :in_revision,
                         :invited_for_full_submission],
                  to: :submitted,
                  guards: :metadata_tasks_completed?,
                  after: [:set_submitting_user_and_touch!,
                          :set_submitted_at!,
                          :set_first_submitted_at!,
                          :prevent_edits!,
                          :expire_permissions_cache]

    end

    event(:invite_full_submission) do
      transitions from: :initially_submitted,
                  to: :invited_for_full_submission,
                  after: [:allow_edits!,
                          :new_minor_version!,
                          :expire_permissions_cache]

    end

    event(:minor_check) do
      transitions from: :submitted,
                  to: :checking,
                  after: [:allow_edits!,
                          :new_minor_version!,
                          :expire_permissions_cache]
    end

    event(:submit_minor_check) do
      transitions from: :checking,
                  to: :submitted,
                  after: [:set_submitting_user_and_touch!,
                          :prevent_edits!,
                          :expire_permissions_cache]
    end

    event(:minor_revision) do
      transitions from: :submitted,
                  to: :in_revision,
                  after: [:allow_edits!,
                          # there is a terminology mismatch here: it
                          # needs MINOR revision but we use a MAJOR
                          # version to track all papers send back
                          # after peer review.
                          :new_major_version!,
                          :expire_permissions_cache]
    end

    event(:major_revision) do
      transitions from: :submitted,
                  to: :in_revision,
                  after: [:allow_edits!,
                          :new_major_version!,
                          :expire_permissions_cache]
    end

    event(:accept) do
      transitions from: :submitted,
                  to: :accepted,
                  after: [:set_accepted_at!,
                          :expire_permissions_cache]
    end

    event(:reject) do
      transitions from: [:initially_submitted, :submitted],
                  to: :rejected,
                  after: [:expire_permissions_cache]
      before do
        update(active: false)
      end
    end

    event(:publish) do
      transitions from: :submitted,
                  to: :published,
                  after: [:set_published_at!,
                          :expire_permissions_cache]
    end

    event(:withdraw) do
      transitions to: :withdrawn,
                  after: [:prevent_edits!,
                          :expire_permissions_cache]
      before do |withdrawal_reason|
        update(active: false)
        withdrawals << { previous_publishing_state: publishing_state,
                         previous_editable: editable,
                         reason: withdrawal_reason }
      end
    end

    event(:reactivate) do
      # AASM doesn't currently allow transitions to dynamic states, so this iterator
      # explicitly defines each transition
      Paper.aasm.states.map(&:name).each do |state|
        transitions from: :withdrawn,
                    to: state,
                    after: [:set_editable!,
                            :expire_permissions_cache],
                            if: Proc.new { previous_state_is?(state) }
      end
      before do
        update(active: true)
      end
    end
  end

  # States which should generally be editable by the creator
  EDITABLE_STATES = [:unsubmitted, :in_revision, :invited_for_full_submission,
                     :checking]
  # States which should generally NOT be editable by the creator
  UNEDITABLE_STATES = [:initially_submitted, :submitted, :accepted, :rejected,
                       :published, :withdrawn]

  def users_with_role(role)
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

  def make_decision(decision)
    public_send "#{decision.verdict}!"
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
      latest_version.update(original_text: new_body)
      notify(action: "updated") unless changed?
    end
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

  def short_title
    answer = answer_for('publishing_related_questions--short_title')
    answer ? answer.value : ''
  end

  def latest_withdrawal_reason
    withdrawals.last[:reason] if withdrawals.present?
  end

  def resubmitted?
    decisions.pending.exists?
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

  %w(admins reviewers).each do |relation|
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

  def authors_list
    authors.map.with_index { |author, index|
      "#{index + 1}. #{author.last_name}, #{author.first_name} from #{author.affiliation}"
    }.join("\n")
  end

  # Return the latest version of this paper.
  # This will ALWAYS return a new instance.
  def latest_version
    versioned_texts(true).version_desc.first
  end

  def insert_figures!
    latest_version.insert_figures!
    notify
  end

  private

  def expire_permissions_cache
    expire_cache_key
    tasks.each(&:expire_cache_key)
    discussion_topics.each(&:expire_cache_key)
  end

  def answer_for(ident)
    nested_question_answers.includes(:nested_question)
      .find_by(nested_questions: { ident: ident })
  end

  def new_major_version!
    latest_version.new_major_version!
  end

  def new_minor_version!
    latest_version.new_minor_version!
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

  def set_submitting_user_and_touch!(submitting_user) # rubocop:disable Style/AccessorMethodName
    latest_version.update!(submitting_user: submitting_user)
    latest_version.touch
  end

  def assign_doi!
    self.update!(doi: DoiService.new(journal: journal).next_doi!) if journal
  end

  def create_versioned_texts
    versioned_texts.create!(major_version: 0, minor_version: 0, \
                            original_text: (@new_body || ''))
  end

  def state_changed?
    previous_changes &&
      previous_changes.key?(:publishing_state) &&
      previous_changes[:publishing_state] != publishing_state
  end

  def state_transition_notifications
    return unless state_changed?

    notify action: publishing_state
    notify action: 'resubmitted' if submitted? && resubmitted?
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
