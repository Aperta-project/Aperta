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

  after_create :assign_user_to_author_tasks

  def self.submitted
    where(submitted: true)
  end

  def self.ongoing
    where(submitted: false)
  end

  def editor
    role = paper_roles.where(editor: true).first
    role.user if role
  end

  def authors_json
    authors.map { |a| a.slice(:first_name, :last_name, :email, :affiliation) }.to_json
  end

  private

  def assign_user_to_author_tasks
    task_manager.phases.collect(&:tasks).flatten.each do |task|
      task.update assignee: user
    end
  end

  def initialize_defaults
    self.paper_type = 'research' if paper_type.blank?
    self.declarations = Declaration.default_declarations if declarations.blank?
    self.task_manager = build_task_manager if task_manager.blank?
  end
end
