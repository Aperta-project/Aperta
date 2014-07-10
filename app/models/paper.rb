class Paper < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :user, inverse_of: :submitted_papers
  belongs_to :journal, inverse_of: :papers
  belongs_to :flow
  belongs_to :locked_by, class_name: User

  has_one :manuscript, dependent: :destroy

  has_many :figures, dependent: :destroy
  has_many :supporting_information_files, class_name: SupportingInformation::File, dependent: :destroy
  has_many :paper_roles, inverse_of: :paper, dependent: :destroy
  has_many :assigned_users, through: :paper_roles, class_name: "User", source: :user
  has_many :phases, -> { order 'phases.position ASC' }, dependent: :destroy
  has_many :tasks, through: :phases
  has_many :journal_roles, through: :journal
  has_many :author_groups, -> { order("id ASC") }, inverse_of: :paper, dependent: :destroy
  has_many :authors, through: :author_groups

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

  def event_stream_serializer
    PaperEventStreamSerializer
  end

  def role_for(role:, user:)
    paper_roles.where(role => true, user_id: user.id)
  end

  def tasks_for_type(klass_name)
    tasks.where(type: klass_name)
  end

  def assignees
    ids = available_admins.pluck(:id) | [user_id]
    User.where(id: ids)
  end

  def available_admins
    journal.admins
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
    admins.first
  end

  def metadata_tasks_completed?
    if tasks.metadata.count != tasks.metadata.completed.count
      errors.add(:base, "can't submit a paper when all of the metadata tasks aren't completed")
    end
  end

  def submitting?
    submitted_changed? && submitted
  end

  def build_default_author_groups
    AuthorGroup.build_default_groups_for(self)
  end

  private
  def notifier_payload
    { id: id, paper_id: id }
  end
end
