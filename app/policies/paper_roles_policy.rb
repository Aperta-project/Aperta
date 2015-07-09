class PaperRolesPolicy < ApplicationPolicy
  primary_resource :paper_role

  def show?
    papers_policy.show?
  end

  private

  def papers_policy
    @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: paper_role.paper)
  end
end
