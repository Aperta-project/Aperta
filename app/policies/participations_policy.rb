class ParticipationsPolicy < ApplicationPolicy
  require_params :task
  include TaskAccessCriteria

  def show?
    current_user.admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end

  def create?
    current_user.admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end

  def destroy?
    current_user.admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    task_owner? || allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end
end
