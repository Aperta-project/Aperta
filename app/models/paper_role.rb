class PaperRole < ActiveRecord::Base
  belongs_to :user
  belongs_to :paper

  after_save :assign_tasks_to_editor, if: -> { user_id_changed? && editor? }

  def self.reviewers_for(paper)
    where(paper_id: paper.id, reviewer: true)
  end

  def self.admins
    where(admin: true)
  end

  protected

  def assign_tasks_to_editor
    query = Task.where(role: 'editor', completed: false, phase_id: paper.task_manager.phases.pluck(:id))
    query = if user_id_was.present?
              query.where('assignee_id IS NULL OR assignee_id = ?', user_id_was)
            else
              query
            end
    query.update_all(assignee_id: user_id)
  end

end
