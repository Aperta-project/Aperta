class Task < ActiveRecord::Base
  include EventStreamNotifier
  include Commentable

  cattr_accessor :metadata_types

  default_scope { order("completed ASC") }

  after_initialize :initialize_defaults

  scope :completed,   -> { where(completed: true) }
  scope :metadata,    -> { where(type: metadata_types) }
  scope :incomplete,  -> { where(completed: false) }
  scope :unassigned,  -> { where(assignee: nil) }

  has_one :paper, through: :phase
  has_one :journal, through: :paper
  has_many :questions, inverse_of: :task
  has_many :participations, inverse_of: :task, dependent: :destroy
  has_many :participants, through: :participations

  validates :title, :role, presence: true
  validates :title, length: { maximum: 255 }

  belongs_to :assignee, class_name: 'User'
  belongs_to :phase, inverse_of: :tasks

  delegate :assignees, to: :paper

  def self.assigned_to(*users)
    #TODO: this is a stopgap until user <-> task relationship table can be established
    assigned_tasks   = Task.where.not(type: "MessageTask").where(assignee: users).pluck(:id)
    message_tasks    = MessageTask.joins(phase: :paper).where("papers.id" => Paper.where(user: users)).pluck(:id)

    where(id: (assigned_tasks + message_tasks))
  end

  def self.for_admins
    where(role: 'admin')
  end

  def self.without(task)
    where.not(id: task.id)
  end

  def is_metadata?
    return false unless Task.metadata_types.present?
    Task.metadata_types.include?(self.class.name)
  end

  def array_attributes
    [:body, :participant_ids]
  end

  def permitted_attributes
    [:assignee_id, :completed, :title, :phase_id, participant_ids: []]
  end

  class << self
    attr_reader :_default_title, :_default_role

    %w(title role).each do |attr|
      define_method attr do |default_attr|
        instance_variable_set :"@_default_#{attr}", default_attr
      end
    end
  end

  def update_responder
    UpdateResponders::Task
  end

  def authorize_update?(params, user)
    true
  end

  protected

  def initialize_defaults
    self.title = self.class._default_title if title.blank?
    self.role = self.class._default_role || 'admin' if role.blank?
  end

  private

  def notifier_payload
    { task_id: id, paper_id: paper.id }
  end
end
