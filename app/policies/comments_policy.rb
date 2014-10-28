class CommentsPolicy < ApplicationPolicy
  require_params :task
  include TaskAccessCriteria

  def show?
    authorized_to_modify_task?
  end

  def create?
    authorized_to_modify_task?
  end

  private
  def authorized_to_modify_task?
    current_user.site_admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || metadata_task_collaborator? || allowed_reviewer_task? || task_participant?
  end
end
