class QuestionAttachmentsPolicy < ApplicationPolicy
  require_params :task
  include TaskAccessCriteria

  def destroy?
    current_user.site_admin? || metadata_task_collaborator? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? || task_participant?
  end

end
