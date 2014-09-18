class CommentsPolicy < ApplicationPolicy
  require_params :task
  include TaskAccessCriteria

  def show?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

  def create?
    current_user.admin? || task_owner? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper?
  end

end
