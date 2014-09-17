class CommentsPolicy < ApplicationPolicy
  require_params :task

  def show?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

  def create?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

  private

  def paper
    task.paper
  end

  def journal_roles
    current_user.roles.where(journal_id: task.journal.id)
  end

  def task_owner?
    task.assignee_id == current_user.id
  end

  def metadata_task_collaborator?
    task.is_metadata? && task.paper.collaborators.exists?(current_user)
  end

  def can_view_all_manuscript_managers_for_journal?
    journal_roles.merge(Role.can_view_all_manuscript_managers).exists?
  end

  def can_view_manuscript_manager_for_paper?
    (paper.tasks.assigned_to(current_user).include?(task) ||
    PaperRole.for_user(current_user).where(paper: paper).exists?) &&
    journal_roles.merge(Role.can_view_assigned_manuscript_managers).exists?
  end
end
