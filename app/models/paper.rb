class Paper < ActiveRecord::Base
  after_initialize :initialize_defaults

  has_one :task_manager, inverse_of: :paper

  belongs_to :user, inverse_of: :papers
  belongs_to :journal, inverse_of: :papers
  belongs_to :flow

  has_many :figures
  has_many :paper_roles, inverse_of: :paper
  has_many :assigned_users, through: :paper_roles, class_name: "User", source: :user
  has_many :available_users, through: :journal_roles, class_name: "User", source: :user

  has_many :phases, -> { order 'phases.position ASC' }, through: :task_manager
  has_many :tasks, through: :phases
  has_many :message_tasks, -> { where(type: 'MessageTask') }, through: :phases, source: :tasks
  has_many :journal_roles, through: :journal

  serialize :authors, Array

  validates :paper_type, presence: true
  validates :short_title, presence: true, uniqueness: true, length: {maximum: 50}
  validates :journal, presence: true
  validate :metadata_tasks_completed?, if: :submitting?

  after_create :assign_user_to_author_tasks

  def self.submitted
    where(submitted: true)
  end

  def self.ongoing
    where(submitted: false)
  end

  def self.published
    where.not(published_at: nil)
  end

  def self.unpublished
    where(published_at: nil)
  end

  def tasks_for_type(klass_name)
    tasks.where(type: klass_name)
  end

  def assignees
    (available_admins + [user]).uniq
  end

  def available_admins
    available_users.merge(JournalRole.admins)
  end

  def admins
    assigned_users.merge(PaperRole.admins)
  end

  def editors
    assigned_users.merge(PaperRole.editors)
  end

  def reviewers
    assigned_users.merge(PaperRole.reviewers)
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

  def admin
    role = paper_roles.where(admin: true).first
    role.user if role
  end

  def metadata_tasks_completed?
    if tasks.metadata.count != tasks.metadata.completed.count
      errors.add(:base, "can't submit a paper when all of the metadata tasks aren't completed")
    end
  end

  def submitting?
    submitted_changed? && submitted
  end

  def add_author(user)
    authors.push user.slice(*%w(first_name last_name email))
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
      self.task_manager ||= build_task_manager
    end
  end
end
