class PaperRole < ActiveRecord::Base
  include EventStreamNotifier

  REVIEWER = 'reviewer'
  EDITOR = 'editor'
  COLLABORATOR = 'collaborator'
  ADMIN = 'admin'

  ALL_ROLES = [REVIEWER, EDITOR, COLLABORATOR, ADMIN]

  belongs_to :user, inverse_of: :paper_roles
  belongs_to :paper, inverse_of: :paper_roles

  validates :paper, presence: true

  after_save :assign_tasks_to_editor, if: -> { user_id_changed? && role == EDITOR }

  validates_uniqueness_of :role, scope: [:user_id, :paper_id]
  validates_inclusion_of :role, within: ALL_ROLES

  def self.admins
    where(role: ADMIN)
  end

  def self.for_user(user)
    where(user: user)
  end

  def self.editors
    where(role: EDITOR)
  end

  def self.reviewers
    where(role: REVIEWER)
  end

  def self.collaborators
    where(role: COLLABORATOR)
  end

  def self.reviewers_for(paper)
    reviewers.where(paper_id: paper.id)
  end

  def self.most_recent_for(user)
    select("paper_id, max(created_at) as max_created").for_user(user).group(:paper_id).order("max_created DESC")
  end

  def description
    role.capitalize
  end

  private

  def notifier_payload
    { paper_id: paper.id, user_id: user.id, id: id }
  end

  protected

  def assign_tasks_to_editor
    query = Task.where(role: 'editor', completed: false, phase_id: paper.phase_ids)
    query = if user_id_was.present?
              query.where('assignee_id IS NULL OR assignee_id = ?', user_id_was)
            else
              query
            end
    query.update_all(assignee_id: user_id)
  end
end
