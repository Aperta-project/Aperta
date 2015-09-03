class Task < ActiveRecord::Base
  include EventStream::Notifiable
  include TaskTypeRegistration
  include Commentable

  register_task default_title: "Ad-hoc", default_role: "user"

  cattr_accessor :metadata_types
  cattr_accessor :submission_types

  scope :metadata, -> { where(type: metadata_types.to_a) }
  scope :submission, -> { where(type: submission_types.to_a) }

  # Scopes based on assignment
  scope :unassigned, -> { includes(:participations).where(participations: { id: nil }) }

  # Scopes based on state
  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }

  scope :on_journals, ->(journals) { joins(:journal).where("journals.id" => journals.map(&:id)) }

  has_one :paper, through: :phase
  has_one :journal, through: :paper
  has_many :attachments
  has_many :questions, inverse_of: :task, dependent: :destroy
  has_many :participations, inverse_of: :task, dependent: :destroy
  has_many :participants, through: :participations, source: :user

  belongs_to :phase, inverse_of: :tasks

  acts_as_list scope: :phase

  validates :title, :role, presence: true
  validates :title, length: { maximum: 255 }

  class << self
    # Public: Scopes the tasks with a given role
    #
    # role  - The String of role name.
    #
    # Examples
    #
    #   for_role('editor')
    #   # => #<ActiveRecord::Relation [<#Task:123>]>
    #
    # Returns ActiveRecord::Relation with tasks.
    def for_role(role)
      where(role: role)
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
      joins(:phase).where(phases: { paper_id: paper })
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
        joins(participations: :user).where("participations.user_id" => users)
      end
    end
  end

  def journal_task_type
    journal.journal_task_types.find_by(kind: self.class.name)
  end

  def metadata_task?
    return false if Task.metadata_types.blank?
    Task.metadata_types.include?(self.class.name)
  end

  def submission_task?
    return false if Task.submission_types.blank?
    Task.submission_types.include?(self.class.name)
  end

  def array_attributes
    [:body]
  end

  def incomplete!
    update(completed: false)
  end

  def update_responder
    UpdateResponders::Task
  end

  def allow_update?
    true
  end

  # Implement this method for Cards that inherit from Task
  def after_update
  end

  def notify_new_participant(current_user, participation)
    UserMailer.delay.add_participant current_user.id, participation.user_id, id
  end

  # Public: This method can be used by models associated with tasks before
  # validation, see ReviewerReportTask and Question model for example usage.
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

  private

  def on_card_completion?
    previous_changes["completed"] == [false, true]
  end


end
