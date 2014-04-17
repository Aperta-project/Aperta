class Task < ActiveRecord::Base
  include EventStreamNotifier

  default_scope { order("completed ASC") }

  after_initialize :initialize_defaults

  scope :completed, -> { where(completed: true) }
  scope :incomplete, -> { where(completed: false) }
  scope :assigned_to, ->(user) { where(assignee: user) }

  has_one :task_manager, through: :phase
  has_one :paper, through: :task_manager
  has_one :journal, through: :paper
  has_many :journal_roles, through: :journal

  has_many :assignees, -> { where("journal_roles.admin" => true) }, through: :journal_roles, source: :user

  validates :title, :role, presence: true

  belongs_to :assignee, class_name: 'User'
  belongs_to :phase, inverse_of: :tasks

  def self.assigned_to(*users)
    where(assignee: users)
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

  def authorize_update!(params, user)
    true
  end

  protected

  def initialize_defaults
    self.title = self.class._default_title if title.blank?
    self.role = self.class._default_role if role.blank?
  end
end
