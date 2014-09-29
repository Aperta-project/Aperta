class TasksPolicy < ApplicationPolicy
  allow_params :task
  include TaskAccessCriteria

  def show?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

  def create?
    current_user.admin?
  end

  def update?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

  def upload?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

  def collaborators?
    current_user.admin? || task_owner? || metadata_task_collaborator? || has_sufficient_role?
  end

  def non_collaborators?
    current_user.admin? || task_owner? || metadata_task_collaborator? || has_sufficient_role?
  end

  def destroy?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end
end
