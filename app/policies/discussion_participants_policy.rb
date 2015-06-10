class DiscussionParticipantsPolicy < ApplicationPolicy
  primary_resource :discussion_participant

  def create?
    topic_policy.update?
  end
  alias :destroy? :create?

  private

  def topic_policy
    @topic_policy ||= DiscussionTopicsPolicy.new(current_user: current_user, discussion_topic: discussion_participant.discussion_topic, paper: discussion_participant.discussion_topic.paper)
  end

end
