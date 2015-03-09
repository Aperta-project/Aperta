class Task < ActiveRecord::Base
  include EventStreamNotifier
  include TaskTypeRegistration
  include Commentable

  register_task default_title: "Ad-hoc", default_role: "user"

  cattr_accessor :metadata_types

  scope :metadata,    -> { where(type: metadata_types) }

  # Scopes based on assignment
  scope :unassigned, -> { includes(:participations).where(participations: { id: nil }) }

  # Scopes based on state
  scope :completed,   -> { where(completed: true) }
  scope :incomplete,  -> { where(completed: false) }


  scope :on_journals, ->(journals) { joins(:journal).where("journals.id" => journals.map(&:id)) }

  has_one :paper, through: :phase
  has_one :journal, through: :paper
  has_many :attachments, as: :attachable
  has_many :questions, inverse_of: :task
  has_many :participations, inverse_of: :task, dependent: :destroy
  has_many :participants, through: :participations, source: :user
  has_many :invitations, inverse_of: :task

  validates :title, :role, presence: true
  validates :title, length: { maximum: 255 }

  belongs_to :phase, inverse_of: :tasks

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
      [:completed, :title, :phase_id]
    end

    def assigned_to(*users)
      if users.empty?
        Task.none
      else
        joins(participations: :user).where("participations.user_id" => users)
      end
    end
  end

  #TODO Research how task generation and templating can be simplified
  # https://www.pivotaltracker.com/story/show/81718250
  def journal_task_type
    journal.journal_task_types.find_by(kind: self.class.name)
  end

  def submission_task?
    return false unless Task.metadata_types.present?
    Task.metadata_types.include?(self.class.name)
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

  def authorize_update?(params, user)
    true
  end
end
