class DiscussionRepliesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    topic = accessible_topics.find(creation_params[:discussion_topic_id])
    reply = topic.discussion_replies.create(creation_params)
    respond_with(reply)
  end

  def update
    topic = accessible_topics.find(params[:id])
    topic.update(update_params)
    respond_with(reply)
  end

  def destroy
    reply = accessible_topics.find(params[:id])
    reply.destroy
    respond_with(reply)
  end

  private

  def creation_params
    params.require(:discussion_reply).permit(:body, :discussion_topic_id).merge(replier: current_user)
  end

  def update_params
    params.require(:discussion_reply).permit(:body)
  end

  def accessible_topics
    paper.discussion_topics.including(current_user)
  end

  def enforce_policy
    true #authorize_action!(paper: paper)
  end
end
