class AdhocEmailsPolicy < ApplicationPolicy
  require_params :task
  include TaskAccessCriteria

  def send_message?
    current_user.admin? || can_view_all_manuscript_managers_for_journal? || can_view_manuscript_manager_for_paper? ||
    allowed_manuscript_information_task? || allowed_reviewer_task? || task_participant?
  end
end
