class AuthorsPolicy < ApplicationPolicy
  primary_resource :author
  include TaskAccessCriteria

  def show?
    papers_policy.show?
  end

  def show?
    authorized_to_modify_task?
  end

  def create?
    authorized_to_modify_task?
  end

  def update?
    authorized_to_modify_task?
  end

  def destroy?
    authorized_to_modify_task?
  end

  private

  def task
    author.authors_task
  end

  def papers_policy
    @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: author.paper)
  end
end
