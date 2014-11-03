class Task < ActiveRecord::Base
  include EventStreamNotifier
  include TaskTypeRegistration
  include Commentable

  register_task default_title: "Ad-hoc", default_role: "user"

  cattr_accessor :metadata_types

  default_scope { order("completed ASC") }

  scope :completed,   -> { where(completed: true) }
  scope :metadata,    -> { where(type: metadata_types) }
  scope :incomplete,  -> { where(completed: false) }

  has_one :paper, through: :phase
  has_one :journal, through: :paper
  has_many :questions, inverse_of: :task
  has_many :participations, inverse_of: :task, dependent: :destroy
  has_many :participants, through: :participations

  validates :title, :role, presence: true
  validates :title, length: { maximum: 255 }

  belongs_to :phase, inverse_of: :tasks


  def self.assigned_to(*users)
    if users.empty?
      Task.none
    else
      joins(participations: :participant).where("participations.participant_id" => users)
    end
  end

  def self.unassigned
    joins("LEFT OUTER JOIN participations ON tasks.id = participations.task_id").where("participations.id" => nil)
  end

  def self.for_role(role)
    where(role: role)
  end

  def self.without(task)
    where.not(id: task.id)
  end

  #TODO Research how task generation and templating can be simplified
  # https://www.pivotaltracker.com/story/show/81718250
  def journal_task_type
    journal.journal_task_types.find_by(kind: self.class.name)
  end

  def is_metadata?
    return false unless Task.metadata_types.present?
    Task.metadata_types.include?(self.class.name)
  end

  def manuscript_information_task?
    self.role == "author"
  end

  def array_attributes
    [:body]
  end

  def permitted_attributes
    [:completed, :title, :phase_id]
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

  private

  def notifier_payload
    { task_id: id, paper_id: paper.id }
  end
end
