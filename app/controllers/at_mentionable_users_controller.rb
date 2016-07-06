# A controller for retrieving lists of of at_mentionable users
class AtMentionableUsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    users = User.who_can :be_at_mentioned, discussion_topic
    respond_with(
      users,
      each_serializer: SensitiveInformationUserSerializer,
      root: :users
    )
  end

  private

  # create a new instance of discussion_topic to determine permissions
  def discussion_topic
    @discussion_topic ||= DiscussionTopic.new(paper: paper)
  end

  def paper
    @paper ||= Paper.find(paper_id)
  end

  def paper_id
    params.require(:on_paper_id)
  end
end
