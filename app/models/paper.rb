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
  include CustomCastTypes

  # PREPRINT_DOI_PREFIX_ID = "10.24196/".freeze
  # PREPRINT_DOI_PREFIX_NAME = "aarx.".freeze

  attribute :title, HtmlString.new
  attribute :abstract, HtmlString.new

  self.snapshottable = true

  belongs_to :journal, inverse_of: :papers

  # Attachment-related things
  has_many :figures, as: :owner, dependent: :destroy
  has_many :question_attachments, dependent: :destroy
  has_many :supporting_information_files, dependent: :destroy
  has_many :adhoc_attachments, dependent: :destroy
  has_one :file,       as: :owner, dependent: :destroy, class_name: 'ManuscriptAttachment'
  has_one :sourcefile, as: :owner, dependent: :destroy, class_name: 'SourcefileAttachment'

  # Everything else
  has_many :versioned_texts, dependent: :destroy
  has_many :similarity_checks, through: :versioned_texts
  has_many :billing_logs, dependent: :destroy, foreign_key: 'documentid'
  has_many :assigned_users, -> { uniq }, through: :assignments, source: :user
  has_many :phases, -> { order 'phases.position ASC' },
           dependent: :destroy,
           inverse_of: :paper
  has_many :tasks, inverse_of: :paper
  has_many :card_versions, through: :tasks
  has_many :comments, through: :tasks
  has_many :comment_looks, through: :comments
  has_many :journal_roles, through: :journal
  has_many :activities, as: :subject
  has_many :decisions, dependent: :destroy
  has_many :discussion_topics, inverse_of: :paper, dependent: :destroy
  has_many :snapshots, dependent: :destroy
  has_many :notifications, inverse_of: :paper
  has_many :answers
  has_many :assignments, as: :assigned_to
  has_many :roles, through: :assignments
  has_many :related_articles, dependent: :destroy
  has_many :withdrawals, dependent: :destroy
  has_many :correspondence

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

  class InvalidPreprintDoiError < ::StandardError; end
  PREPRINT_DOI_ARTICLE_NUMBER_LENGTH = 7
  PREPRINT_DOI_PREFIX = "10.24196".freeze
  PREPRINT_DOI_FORMAT = %r{
    \A
    #{PREPRINT_DOI_PREFIX}
    /aarx\.
    \d{#{PREPRINT_DOI_ARTICLE_NUMBER_LENGTH }}
  \z}x

  validates :preprint_doi_article_number,
    format: {
      with: %r{\A\d{#{PREPRINT_DOI_ARTICLE_NUMBER_LENGTH}}\z},
      message: 'The Preprint DOI article number is not valid. It can only contain a string of integers',
      if: proc { |paper| paper.preprint_doi_article_number.present? }
  }

  scope :active,   -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # we will want an index on this at some point, maybe not this point
  # https://github.com/Casecommons/pg_search/wiki/Building-indexes
  pg_search_scope :pg_title_search,
                  against: :title,
                  using: {
                    tsearch: { dictionary: "english" } # stems
                  }

  delegate :major_version, :minor_version,
           to: :latest_submitted_version, allow_nil: true
  delegate :figureful_text,
           to: :latest_version, allow_nil: true

  def self.find_preprint_doi_article_number(full_preprint_doi)
    full_preprint_doi.match(/.+\.(\d+)/)[1]
  end

  def file_type
    file.try(:file_type)
  end

  def manuscript_id
    journal_prefix_and_number = doi.split('/').last.split('.') if doi
    journal_prefix_and_number.try(:shift) # Remove 'journal' text
    journal_prefix_and_number.try(:join, '.')
  end

  def to_param
    short_doi
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
                  guards: [:required_for_submission_tasks_completed?],
                  after: [:assign_submitting_user!,
                          :set_submitted_at!,
                          :set_first_submitted_at!,
                          :prevent_edits!,
                          :new_minor_version!,
                          :after_paper_submitted]
    end

    event(:submit) do
      # Major version numbers represent the number of times
      # the manuscript has been revised. Initial submissions
      # and first full submissions are not revisions, and
      # so they do not increment that number.
      transitions from: [:in_revision],
                  to: :submitted,
                  guards: [:metadata_tasks_completed?,
                           :required_for_submission_tasks_completed?],
                  after: [:assign_submitting_user!,
                          :set_submitted_at!,
                          :set_first_submitted_at!,
                          :prevent_edits!,
                          :new_major_version!,
                          :after_paper_submitted]
      transitions from: [:unsubmitted,
                         :invited_for_full_submission],
                  to: :submitted,
                  guards: [:metadata_tasks_completed?,
                           :required_for_submission_tasks_completed?],
                  after: [:assign_submitting_user!,
                          :set_submitted_at!,
                          :set_first_submitted_at!,
                          :prevent_edits!,
                          :new_minor_version!,
                          :after_paper_submitted]
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
        withdrawal_reason || raise(ArgumentError, "withdrawal_reason must be provided")
        withdrawn_by_user || raise(ArgumentError, "withdrawn_by_user must be provided")
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
        transitions from: :withdrawn, to: state, after: :set_editable!, if: proc { previous_state_is?(state) }
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
                          :new_minor_version!,
                          :after_paper_submitted]
    end
  end

  # All known paper states
  STATES = aasm.states.map(&:name).freeze
  # States which should generally be editable by the creator
  EDITABLE_STATES = [:unsubmitted, :in_revision, :invited_for_full_submission,
                     :checking].freeze
  # States which should generally NOT be editable by the creator
  UNEDITABLE_STATES = [:initially_submitted, :submitted, :accepted, :rejected,
                       :published, :withdrawn].freeze
  # States that represent the creator has submitted their paper
  SUBMITTED_STATES = [:initially_submitted, :submitted].freeze
  # States that represent when a paper can be reviewed by a Reviewer
  REVIEWABLE_STATES = (EDITABLE_STATES + SUBMITTED_STATES).freeze

  TERMINAL_STATES = [:accepted, :rejected].freeze

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
      'assignments.assigned_to_type' => 'Paper'
    )
  end

  def self.find_by_id_or_short_doi(id)
    return find_by_short_doi(id) if id.to_s =~ Journal::SHORT_DOI_FORMAT
    find(id)
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
      latest_version.update(original_text: new_body, file_type: file_type)
      notify(action: "updated") unless changed?
    end
  end

  # Returns the corresponding authors. When there are no authors
  # marked as corresponding then it defaults to the creator.
  def corresponding_authors
    corresponding_authors = authors.select(&:corresponding?)
    corresponding_authors << creator if corresponding_authors.empty?
    corresponding_authors.compact
  end

  def co_authors
    authors.reject { |author| author.user == creator }
  end

  # Returns the corresponding author emails. When there are no authors
  # marked as corresponding then it defaults to the creator's email address.
  def corresponding_author_emails
    corresponding_authors.map(&:email)
  end

  # Downloads the manuscript from the given URL.
  def download_manuscript!(url, uploaded_by:)
    attachment = file || create_file
    old_file_hash = attachment.file_hash
    attachment.download!(url, uploaded_by: uploaded_by)
    if attachment.file_hash == old_file_hash
      alert_duplicate_file(attachment, uploaded_by)
      # No need to process attachment, mark the paper record as "done"
      update(processing: false)
    end
  end

  # Downloads the sourcefile from the given URL.
  def download_sourcefile!(url, uploaded_by:)
    attachment = sourcefile || create_sourcefile
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

  def display_title(sanitized: true)
    sanitized ? strip_tags(title) : title.html_safe
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

  # TODO: Remove in APERTA-9787
  # Accepts any args the state transition accepts
  def metadata_tasks_completed?(*)
    tasks.metadata.select(&:submission_task?).map(&:completed).all?
  end

  def required_for_submission_tasks_completed?(*)
    tasks.with_card.joins(:card_version).merge(
      CardVersion.required_for_submission
    ).pluck(:completed).all?
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
    assignment = assignments
      .where(user: user, role: journal.collaborator_role)
      .first_or_create!
    notify(action: "add_collaboration")
    assignment
  end

  def remove_collaboration(collaboration)
    if collaboration.is_a?(User)
      collaboration = collaborations.find_by(user: collaboration)
    elsif !collaboration.is_a?(Assignment)
      collaboration = collaborations.find_by(id: collaboration)
    end

    collaboration.destroy if collaboration.role == journal.collaborator_role
    notify(action: "remove_collaboration")

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
    decisions.create.tap(&:create_invitation_queue!) unless draft_decision
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
    answers.includes(:card_content)
           .find_by(card_contents: { ident: ident })
  end

  def in_terminal_state?
    TERMINAL_STATES.include? publishing_state.to_sym
  end

  def last_of_task(klass)
    tasks.where(type: klass.to_s).last
  end

  def all_authors
    author_list_items.map(&:author)
  end

  def revise_task
    tasks.find_by(type: 'TahiStandardTasks::ReviseTask')
  end

  # If we add more hooks like this we may want to make this more foolproof, but
  # for now this method is an :after callback on the :submit event (check )
  def after_paper_submitted
    # Some hooks need `paper.previous_changes` so we call the hook with self
    # rather than having the task look it up
    tasks.each { |t| t.after_paper_submitted self }
  end

  def manually_similarity_checked
    similarity_checks.exists? automatic: false
  end

  def ensure_preprint_doi!
    return preprint_doi_article_number if preprint_doi_article_number.present?

    with_lock do
      next_article_number = PreprintDoiIncrementer.next_article_number!
      update preprint_doi_article_number: next_article_number
    end
    preprint_doi_article_number
  end

  def aarx_doi
    return nil unless preprint_doi_suffix
    PREPRINT_DOI_PREFIX + "/" + preprint_doi_suffix
  end

  def preprint_doi_suffix
    return nil unless preprint_doi_article_number
    "aarx." + preprint_doi_article_number
  end

  private

  def assign_preprint_doi!
    raise "Invalid paper Journals are required for papers urls." unless journal
    update!(preprint_doi_short_id: journal.next_preprint_short_doi!)
  end

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
    Activity.state_changed! self, to: aasm.to_state
  end

  def assign_submitting_user!(submitting_user)
    draft.update!(submitting_user: submitting_user)
  end

  def assign_doi!
    raise "Invalid paper Journals are required for papers urls." unless journal
    update!(doi: journal.next_doi!)
    doi_parts = doi.split('.')
    update!(short_doi: doi_parts[-2] + '.' + doi_parts[-1])
  end

  def create_versioned_texts
    versioned_texts.create! major_version: nil,
                            minor_version: nil,
                            original_text: (@new_body || ''),
                            file_type: file_type
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

  def alert_duplicate_file(attachment, uploaded_by)
    TahiPusher::Channel.delay(queue: :eventstream, retry: false)
        .push(channel_name: "private-user@#{uploaded_by.id}",
              event_name: 'flashMessage',
              payload: {
                messageType: 'alert',
                message: "<b>Duplicate file.</b> Please note: " \
                  "The specified file <i>#{attachment.file.filename}</i> " \
                  "has been reprocessed. <br>If you need to make any " \
                  "changes to your manuscript, you can upload again by " \
                  "clicking the <i>Replace</i> link."
              })
  end
end
