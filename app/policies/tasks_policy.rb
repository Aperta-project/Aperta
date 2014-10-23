class TasksPolicy < ApplicationPolicy
  allow_params :task
  include TaskAccessCriteria

  def show?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end

  def create?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

  def update?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end

  def upload?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end

  def destroy?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end
end
