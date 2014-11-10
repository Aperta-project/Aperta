class AuthorsPolicy < ApplicationPolicy
  primary_resource :author

  def connected_users
    papers_policy.connected_users
  end

  def show?
    papers_policy.show?
  end

  private

  def papers_policy
    @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: author.paper)
  end
end
