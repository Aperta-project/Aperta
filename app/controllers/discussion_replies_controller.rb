class DiscussionRepliesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def show
    respond_with(discussion_reply)
  end

  def create
    discussion_reply.save
    respond_with(discussion_reply)
  end

  def update
    discussion_reply.update(update_params)
    respond_with(discussion_reply)
  end

  def destroy
    discussion_reply.destroy
    respond_with(discussion_reply)
  end

  private

  def creation_params
    params.require(:discussion_reply).permit(:body, :discussion_topic_id)
      .merge(replier: current_user)
  end

  def update_params
    params.require(:discussion_reply).permit(:body)
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

  def enforce_policy
    authorize_action!(discussion_reply: discussion_reply)
  end
end
