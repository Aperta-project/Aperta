class QuestionsPolicy < ApplicationPolicy
  require_params :question
  include TaskAccessCriteria

  def create?
    current_user.site_admin? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? || allowed_reviewer_task? || task_participant?
  end

  def update?
    current_user.site_admin? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? || allowed_reviewer_task? || task_participant?
  end

  def destroy?
    current_user.site_admin? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? || allowed_reviewer_task? || task_participant?
  end

  private

  def task
    question.task
  end
end
