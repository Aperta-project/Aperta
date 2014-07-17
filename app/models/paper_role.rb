class PaperRole < ActiveRecord::Base

  belongs_to :user, inverse_of: :paper_roles
  belongs_to :paper, inverse_of: :paper_roles

  validates :paper, presence: true

  after_save :assign_tasks_to_editor, if: -> { user_id_changed? && role == 'editor' }

  def self.admins
    where(role: 'admin')
  end

  def self.for_user(user)
    where(user: user)
  end

  def self.editors
    where(role: 'editor')
  end

  def self.reviewers
    where(role: 'reviewer')
  end

  def self.collaborators
    where(role: 'collaborator')
  end

  def self.reviewers_for(paper)
    reviewers.where(paper_id: paper.id)
  end

  def description
    role.capitalize
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
