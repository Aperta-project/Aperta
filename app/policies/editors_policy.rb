class EditorsPolicy < ApplicationPolicy
  primary_resource :paper

  def destroy?
    papers_policy.show?
  end

  private

  def papers_policy
    @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: paper)
  end
end
