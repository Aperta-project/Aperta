class PaperRolesPolicy < ApplicationPolicy
  primary_resource :paper

  def index?
    manuscript_managers_policy.can_manage_manuscript?
  end

  private

  def manuscript_managers_policy
    @manuscript_managers_policy ||= ManuscriptManagersPolicy.new(current_user: current_user, paper: paper)
  end
end
