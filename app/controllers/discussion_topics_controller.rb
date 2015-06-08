class DiscussionTopicsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def index
    topics = accessible_topics
    respond_with topics, each_serializer: DiscussionTopicIndexSerializer
  end

  def show
    topic = accessible_topics.find(params[:id])
    respond_with topic
  end

  def create
    topic = DiscussionTopic.create(creation_params)
    topic.discussion_replies.create(reply_params)
    topic.discussion_participants.create(user: current_user)
    respond_with topic
  end

  def update
    topic = accessible_topics.find(params[:id])
    topic.update(update_params)
    respond_with topic
  end

  def destroy
    topic = accessible_topics.find(params[:id])
    topic.destroy
    respond_with topic
  end

  private

  def creation_params
    params.require(:discussion_topic).permit(:title).merge(paper_id: paper.id)
  end

  def update_params
    params.require(:discussion_topic).permit(:title)
  end

  def reply_params
    params.require(:discussion_reply).permit(:body).merge(replier: current_user)
  end

  def accessible_topics
    paper.discussion_topics.including(current_user)
  end

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end

  # TODO: enforce an access policy...any code reviewer should catch this...
  def enforce_policy
    true # authorize_action!(paper: paper)
  end
end
