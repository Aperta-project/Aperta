class Task < ActiveRecord::Base
  include EventStreamNotifier

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

  validates :title, :role, presence: true

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

  def array_attributes
    []
  end

  def permitted_attributes
    [:assignee_id, :completed, :title, :body, :phase_id]
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
    self.role = self.class._default_role if role.blank?
  end
end
