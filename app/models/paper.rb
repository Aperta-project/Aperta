class Paper < ActiveRecord::Base
  belongs_to :user, inverse_of: :papers
  belongs_to :journal, inverse_of: :papers
  belongs_to :flow

  has_one :manuscript, dependent: :destroy

  has_many :figures, dependent: :destroy
  has_many :supporting_information_files, class_name: 'SupportingInformation::File', dependent: :destroy
  has_many :paper_roles, inverse_of: :paper, dependent: :destroy
  has_many :assigned_users, through: :paper_roles, class_name: "User", source: :user
  has_many :available_users, through: :journal_roles, class_name: "User", source: :user
  has_many :phases, -> { order 'phases.position ASC' }, dependent: :destroy
  has_many :tasks, through: :phases
  has_many :message_tasks, -> { where(type: 'MessageTask') }, through: :phases, source: :tasks
  has_many :journal_roles, through: :journal

  serialize :authors, Array

  validates :paper_type, presence: true
  validates :short_title, presence: true, uniqueness: true, length: {maximum: 50}
  validates :journal, presence: true
  validate :metadata_tasks_completed?, if: :submitting?

  class << self
    def submitted
      where(submitted: true)
    end

    def ongoing
      where(submitted: false)
    end

    def published
      where.not(published_at: nil)
    end

    def unpublished
      where(published_at: nil)
    end
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
end
