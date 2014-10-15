class Task < ActiveRecord::Base
  include EventStreamNotifier
  include Commentable

  cattr_accessor :metadata_types

  default_scope { order("completed ASC") }

  after_initialize :initialize_defaults

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
