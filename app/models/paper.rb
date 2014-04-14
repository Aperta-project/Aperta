class Paper < ActiveRecord::Base
  PAPER_TYPES = %w(research front_matter)

  after_initialize :initialize_defaults

  belongs_to :user, inverse_of: :papers
  belongs_to :journal, inverse_of: :papers
  belongs_to :flow

  has_many :declarations, -> { order :id }
  has_many :figures
  has_many :paper_roles
  has_many :reviewers, -> { where("paper_roles.reviewer" => true) }, through: :paper_roles, source: :user
  has_many :editors, -> { where("paper_roles.editor" => true) }, through: :paper_roles, source: :user
  has_many :admins, -> { where("paper_roles.admin" => true) }, through: :paper_roles, source: :user

  has_one :task_manager, inverse_of: :paper

  serialize :authors, Array

  validates :paper_type, inclusion: { in: PAPER_TYPES }
  validates :short_title, presence: true, uniqueness: true, length: {maximum: 50}
  validates :journal, presence: true

  has_many :phases, -> { order 'phases.position ASC' }, through: :task_manager
  has_many :tasks, through: :phases
  has_many :message_tasks, -> { where(type: 'MessageTask') }, through: :phases, source: :tasks

  has_many :journal_roles, through: :journal
  has_many :assignees, -> { where("journal_roles.admin" => true) }, through: :journal_roles, source: :user

  after_create :assign_user_to_author_tasks

  def self.submitted
    where(submitted: true)
  end

  def tasks_for_type(klass_name)
    tasks.where(type: klass_name)
  end

  def self.ongoing
    where(submitted: false)
  end

  def display_title
    title.present? ? title : short_title
  end

  def assign_admin!(user)
    transaction do
      paper_roles.admins.destroy_all
      paper_roles.admins.create!(user: user)
    end
  end

  def editor
    role = paper_roles.where(editor: true).first
    role.user if role
  end

  def admin
    role = paper_roles.where(admin: true).first
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
    unless persisted?
      self.paper_type = 'research' if self.paper_type.blank?
      self.declarations = Declaration.default_declarations unless (self.declarations.exists? || self.declarations.any?)
      self.task_manager ||= build_task_manager
    end
  end
end
