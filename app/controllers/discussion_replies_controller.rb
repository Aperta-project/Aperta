class DiscussionRepliesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can :view, discussion_reply.discussion_topic
    respond_with(discussion_reply)
  end

  def create
    requires_user_can :reply, discussion_reply.discussion_topic
    discussion_reply.save
    respond_with(discussion_reply)
  end

  private

  def creation_params
    params.require(:discussion_reply).permit(:body, :discussion_topic_id)
      .merge(replier: current_user)
  end

  def discussion_reply
    @discussion_reply ||= begin
      if params[:id].present?
        DiscussionReply.find(params[:id])
      elsif params[:discussion_reply].present?
        DiscussionReply.new(creation_params)
      end
    end
  end
end
