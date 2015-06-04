class DiscussionTopicsPolicy < ApplicationPolicy
  primary_resource :discussion_topic

  def connected_users
    discussion_topic.discussion_participants
  end

  def index?
    @papers_policy.show?
  end

  def show?
    false
  end

  def create?
    @papers_policy.show?
  end

  def update?
    false
  end

  def destroy?
    false
  end

  private

  def papers_policy
    @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: discussion_topic.paper)
  end

end
