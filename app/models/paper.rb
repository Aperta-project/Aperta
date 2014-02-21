class Paper < ActiveRecord::Base
  PAPER_TYPES = %w(research front_matter)

  after_initialize :initialize_defaults

  belongs_to :user
  belongs_to :journal

  has_many :declarations, -> { order :id }
  has_many :figures
  has_many :paper_roles

  has_one :task_manager

  accepts_nested_attributes_for :declarations
  serialize :authors, Array

  validates :paper_type, inclusion: { in: PAPER_TYPES }
  validates :short_title, presence: true, uniqueness: true, length: {maximum: 50}
  validates :journal, presence: true

  delegate :phases, to: :task_manager
  delegate :tasks, to: :task_manager

  after_create :assign_user_to_author_tasks

  def self.submitted
    where(submitted: true)
  end

  def display_title
    title.present? ? title : short_title
  end

  def self.ongoing
    where(submitted: false)
  end

  def editor
    role = paper_roles.where(editor: true).first
    role.user if role
  end

  private

  def assign_user_to_author_tasks
    phase_ids = task_manager.phases.pluck(:id)

    Task.where(phase_id: phase_ids, role: 'author').each do |task|
      task.update assignee: user
    end
  end

  def initialize_defaults
    self.paper_type = 'research' if paper_type.blank?
    self.declarations = Declaration.default_declarations if declarations.blank?
    self.task_manager = build_task_manager if task_manager.blank?
  end
end
