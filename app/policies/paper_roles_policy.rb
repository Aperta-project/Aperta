class PaperRolesPolicy < ApplicationPolicy
  primary_resource :paper_role

  def connected_users
    papers_policy.connected_users
  end

  def show?
    papers_policy.show?
  end

  private

  def papers_policy
    @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: paper_role.paper)
  end
end
