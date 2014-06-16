class TasksPolicy < ApplicationPolicy
  allow_params :task

  def show?
    current_user.admin? || task_owner? || has_sufficient_role?
  end

  def edit?
    current_user.admin? || author? || paper_admin? || paper_editor? || paper_reviewer?
  end

  def create?
    current_user.admin?
  end

  def update?
    current_user.admin? || task_owner? || has_sufficient_role?
  end

  def upload?
    current_user.admin? || task_owner? || has_sufficient_role?
  end

  def destroy?
    current_user.admin? || task_owner? || has_sufficient_role?
  end

  private

  def task_owner?
    current_user.tasks.where(id: task.id).first
  end

  def has_sufficient_role?
    current_user.roles.where(journal_id: task.journal.id, can_view_all_manuscript_managers: true).present?
  end
end

