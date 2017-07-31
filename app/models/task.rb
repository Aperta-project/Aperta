class Task < ActiveRecord::Base
  include Answerable
  include EventStream::Notifiable
  include Commentable
  include Snapshottable
  include CustomCastTypes

  DEFAULT_TITLE = 'SUBCLASSME'.freeze
  DEFAULT_ROLE_HINT = 'user'.freeze

  REQUIRED_PERMISSIONS = {}.freeze
  SYSTEM_GENERATED = false

  cattr_accessor :metadata_types
  cattr_accessor :submission_types

  before_save :on_completion, if: :completed_changed?

  scope :metadata, -> { where(type: metadata_types.to_a) }
  scope :submission, -> { where(type: submission_types.to_a) }
  scope :of_type, -> (task_type) { where(type: task_type) }

  # TODO: Remove in APERTA-9787
  # Because all tasks should have a card then
  scope :with_card, -> { where.not(card_version_id: nil) }

  # Scopes based on assignment
  scope :unassigned, lambda {
    includes(:assignments).where(assignments: { id: nil })
  }

  # Scopes based on state
  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }

  scope :on_journals, lambda { |journals|
    joins(:journal).where('journals.id' => journals.map(&:id))
  }

  has_many \
    :participations,
    -> { joins(:role).where(roles: { name: Role::TASK_PARTICIPANT_ROLE }) },
    class_name: 'Assignment',
    as: :assigned_to

  belongs_to :paper, inverse_of: :tasks
  has_one :journal, through: :paper, inverse_of: :tasks
  has_many :assignments, as: :assigned_to, dependent: :destroy
  has_many :reviewer_reports
  has_many :attachments,
           as: :owner,
           class_name: 'AdhocAttachment',
           dependent: :destroy

  belongs_to :phase, inverse_of: :tasks
  belongs_to :task_template

  belongs_to :card_version

  acts_as_list scope: :phase

  validates :paper_id, presence: true
  validates :title, presence: true
  validates :title, length: { maximum: 255 }

  class << self
    # Public: Restores the task defaults to all of its instances/models
    #
    # * restores title to DEFAULT_TITLE
    #
    # Note: this will not restore the +title+ on ad-hoc tasks.
    def restore_defaults
      return if self == Task
      update_all(title: self::DEFAULT_TITLE)
    end

    # Public: Scopes the tasks for a given paper
    #
    # paper  - The paper object
    #
    # Examples
    #
    #   for_paper(Paper.last)
    #   # => #<ActiveRecord::Relation [<#Task:123>]>
    #
    # Returns ActiveRecord::Relation with tasks.
    def for_paper(paper)
      where(paper_id: paper.id)
    end

    # Public: Scopes the tasks without the given task
    #
    # task  - Task object
    #
    # Examples
    #
    #   without(<#Task:123>)
    #   # => #<ActiveRecord::Relation [<#Task:456>]>
    #
    # Returns ActiveRecord::Relation with tasks.
    def without(task)
      where.not(id: task.id)
    end

    # Public: Allows tasks to specify attributes to be whitelisted in requests.
    # Implement this class method in your Task class.
    #
    # Examples
    #
    #   def self.permitted_attributes
    #     super << :custom_attribute
    #   end
    #
    # Returns an Array of attributes.
    def permitted_attributes
      [:completed, :title, :phase_id, :position]
    end

    def assigned_to(*users)
      if users.empty?
        Task.none
      else
        joins(assignments: [:role, :user])
          .where(
            'assignments.user_id' => users,
            'roles.name' => Role::TASK_PARTICIPANT_ROLE
          )
      end
    end

    def delegate_state_to
      :paper
    end

    def metadata_task_types
      descendants.select { |klass| klass <=> MetadataTask }
    end

    def submission_task_types
      descendants.select { |klass| klass <=> SubmissionTask }
    end

    def safe_constantize(str)
      raise StandardError, 'Attempted to constantize disallowed value' \
        unless Task.descendants.map(&:to_s).member?(str)
      str.constantize
    end
  end

  # called in the paper factory both as part of paper creation and when an
  # individual task is added to the workflow.  Remember to call super when
  # subclassing
  def task_added_to_paper(_paper)
    card_version.try(:create_default_answers, self)
  end

  def journal_task_type
    journal.journal_task_types.find_by(kind: self.class.name)
  end

  def metadata_task?
    return false if Task.metadata_types.blank?
    Task.metadata_types.include?(self.class.name)
  end

  def submission_task?
    # TODO: Remove Task.submission_types check in APERTA-9787
    Task.submission_types.include?(self.class.name) ||
      (!card_version.nil? && card_version.required_for_submission)
  end

  def array_attributes
    [:body]
  end

  def complete!
    update!(completed: true)
  end

  def incomplete!
    update!(completed: false)
  end

  def add_participant(user)
    participations.where(
      user: user,
      role: journal.task_participant_role,
      assigned_to: self
    ).first_or_create!
  end

  def participants
    participant_ids = participations.map(&:user).uniq.map(&:id)
    User.where(id: participant_ids)
  end

  def reviewer
    assignments.joins(:role)
      .find_by(roles: { name: Role::REVIEWER_REPORT_OWNER_ROLE }).try(:user)
  end

  def update_responder
    UpdateResponders::Task
  end

  ########### Paper Lifecycle Hooks ########
  # A Task can add specific functionality to a paper via a method on the task
  # instance itself rather than having to rely on ActiveSupport::Notifications
  # The paper is passed in directly to maintain any attributes that might be
  # set on the paper in memory, for instance ``
  def after_paper_submitted(paper)
    # no-op for Task
  end
  ##########################################

  # Implement this method for Cards that inherit from Task
  def after_update
  end

  # This hook runs before the task saves. Note that this hook will run
  # both when the task was just marked completed or uncompleted
  def on_completion
    update_completed_at
  end

  def notify_new_participant(current_user, participation)
    UserMailer.delay.add_participant current_user.id, participation.user_id, id
  end

  # Public: This method can be used by models associated with tasks before
  # validation, see ReviewerReportTask model for example usage.
  #
  # You should override this method in inherited tasks if needed.
  #
  # association_object  - Object associated with task
  #
  # Examples
  #
  #   can_change?(association)
  #   # => true
  #
  # Returns true in this case. You'd typically want to add errors to the passed
  # object to invalidate the object and stop from being saved.
  #
  def can_change?(_)
    true
  end

  def previously_completed?
    previous_changes['completed'] && previous_changes['completed'][0]
  end

  def newly_complete?
    !previously_completed? && completed
  end

  def newly_incomplete?
    previously_completed? && !completed
  end

  # Needed for invitations.
  def invitee_role
    "Override me"
  end

  # Overrides Answerable.  Since Tasks are STI the client needs to be able to
  # save an Answer with the expected owner type (Task) rather than the specific
  # subclass type (ie TahiStandardTasks::ReviewerReportTask)
  def owner_type_for_answer
    'Task'
  end

  def last_reviewer_report_status
    # the most review report is always the first
    reviewer_reports.first.try(:computed_status)
  end

  private

  def update_completed_at
    self.completed_at = (Time.zone.now if completed)
  end
end

Rails.application.config.eager_load_namespaces.each(&:eager_load!)
