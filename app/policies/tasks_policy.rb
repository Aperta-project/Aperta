class TasksPolicy < ApplicationPolicy
  allow_params :task
  include TaskAccessCriteria

  def show?
    authorized_to_modify?
  end

  def create?
    authorized_to_create?
  end

  def update?
    authorized_to_modify?
  end

  def upload?
    authorized_to_modify?
  end

  def destroy?
    authorized_to_modify?
  end

  def send_message?
    authorized_to_modify?
  end

  private
  def authorized_to_modify?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end

  def authorized_to_create?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end
end
