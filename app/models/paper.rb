class Paper < ActiveRecord::Base
  include EventStreamNotifier

  belongs_to :creator, inverse_of: :submitted_papers, class_name: 'User', foreign_key: :user_id
  belongs_to :journal, inverse_of: :papers
  belongs_to :flow
  belongs_to :locked_by, class_name: 'User'
  belongs_to :striking_image, class_name: 'Figure'

  has_one :manuscript, dependent: :destroy

  has_many :figures, dependent: :destroy
  has_many :supporting_information_files, class_name: 'SupportingInformation::File', dependent: :destroy
  has_many :paper_roles, inverse_of: :paper, dependent: :destroy
  has_many :assigned_users, -> { uniq }, through: :paper_roles, source: :user
  has_many :phases, -> { order 'phases.position ASC' }, dependent: :destroy, inverse_of: :paper
  has_many :tasks, through: :phases
  has_many :participants, through: :tasks
  has_many :journal_roles, through: :journal
  has_many :authors, -> { order 'authors.position ASC' }

  validates :paper_type, presence: true
  validates :short_title, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :journal, presence: true
  validate :metadata_tasks_completed?, if: :submitting?

  delegate :admins, :editors, :reviewers, to: :journal, prefix: :possible

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

    def find(param)
      Doi.valid?(param) ? find_by_doi!(param) : super
    end
  end

  def role_for(role:, user:)
    paper_roles.where(role: role, user_id: user.id)
  end

  def tasks_for_type(klass_name)
    tasks.where(type: klass_name)
  end

  def display_title
    title.present? ? title : short_title
  end

  def assign_role!(user, role)
    transaction do
      paper_roles.for_role(role).destroy_all
      paper_roles.for_role(role).create!(user: user)
    end
  end

  def admin
    admins.first
  end

  def editor
    editors.first
  end

  def metadata_tasks_completed?
    return unless uncompleted_tasks?
    errors.add(:base, "can't submit a paper when all of the metadata tasks aren't completed")
  end

  def submitting?
    submitted_changed? && submitted
  end

  def locked?
    locked_by_id.present?
  end

  def unlocked?
    !locked?
  end

  def locked_by?(user)
    locked_by_id == user.id
  end

  def lock_by(user)
    update_attribute(:locked_by, user)
  end

  def unlock
    update_attribute(:locked_by, nil)
  end

  def heartbeat
    update_attribute(:last_heartbeat_at, Time.now)
  end

  %w(admins editors reviewers collaborators).each do |relation|
    # paper.editors   # => [user1, user2]
    define_method relation.to_sym do
      assigned_users.merge(PaperRole.send(relation))
    end

    # paper.editor?(user1)  # => true
    define_method("#{relation.singularize}?".to_sym) do |user|
      return false unless user.present?
      send(relation).exists?(user.id)
    end
  end

  private

  def uncompleted_tasks?
    tasks.metadata.count != tasks.metadata.completed.count
  end
end
