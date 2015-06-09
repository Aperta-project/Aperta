class DiscussionTopicsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def index
    topics = paper.discussion_topics.including(current_user)
    respond_with topics, each_serializer: DiscussionTopicIndexSerializer
  end

  def show
    respond_with discussion_topic
  end

  def create
    discussion_topic.discussion_participants.build(user: current_user)
    discussion_topic.save
    respond_with discussion_topic
  end

  def update
    discussion_topic.update(update_params)
    respond_with discussion_topic
  end

  def destroy
    discussion_topic.destroy
    respond_with discussion_topic
  end

  private

  def creation_params
    params.require(:discussion_topic).permit(:title, :paper_id)
  end

  def update_params
    params.require(:discussion_topic).permit(:title)
  end

  def discussion_topic
    @discussion_topic ||= begin
      if params[:id].present?
        DiscussionTopic.find(params[:id])
      elsif params[:discussion_topic].present?
        DiscussionTopic.new(creation_params)
      end
    end
  end

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end

  def enforce_policy
    if discussion_topic
      authorize_action!(discussion_topic: discussion_topic, paper: discussion_topic.paper)
    else
      # index won't have a singluar topic, but we'll know the paper
      authorize_action!(discussion_topic: nil, paper: paper)
    end
  end

end
