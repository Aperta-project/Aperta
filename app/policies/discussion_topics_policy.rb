class DiscussionTopicsPolicy < ApplicationPolicy
  primary_resource :discussion_topic
  allow_params :paper

  def index?
    papers_policy.show?
  end

  def create?
    papers_policy.update?
  end

  def show?
    papers_policy.show? && participating_in_discussion?
  end
  alias :update? :show?
  alias :destroy? :show?

  private

  def paper
    # either the paper is sent in when this Policy is initialized, or we have a
    # valid discussion_topic and can grab the paper off of the topic.
    @paper ||= discussion_topic.paper
  end

  def participating_in_discussion?
    discussion_topic.discussion_participants.where(user_id: current_user.id).exists?
  end

  def papers_policy
    @papers_policy ||= PapersPolicy.new(current_user: current_user, resource: paper)
  end

end
