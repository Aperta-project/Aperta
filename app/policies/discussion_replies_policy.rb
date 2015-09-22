class DiscussionRepliesPolicy < ApplicationPolicy
  primary_resource :discussion_reply

  def update?
    topic_policy.update?
  end
  alias :create? :update?
  alias :destroy? :update?
  alias :show? :update?

  private

  def topic_policy
    @topic_policy ||= DiscussionTopicsPolicy.new(current_user: current_user, discussion_topic: discussion_reply.discussion_topic, paper: discussion_reply.discussion_topic.paper)
  end

end
