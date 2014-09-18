class TasksPolicy < ApplicationPolicy
  allow_params :task
  include TaskAccessCriteria

  def show?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal?
  end

  def create?
    current_user.admin?
  end

  def update?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal?
  end

  def upload?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal?
  end

  def destroy?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal?
  end
end
