class DiscussionParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    if discussion_participant.save
      topic = discussion_participant.discussion_topic
      topic.notifications.create!(paper: topic.paper, user: discussion_participant.user)
    end
    respond_with discussion_participant
  end

  def destroy
    if discussion_participant.destroy
      topic = discussion_participant.discussion_topic
      topic.notifications.where(user: discussion_participant.user).destroy_all
    end
    respond_with discussion_participant
  end

  private

  def creation_params
    params.require(:discussion_participant).permit(:discussion_topic_id, :user_id)
  end

  def discussion_participant
    @discussion_participant ||= begin
      if params[:id].present?
        DiscussionParticipant.find(params[:id])
      elsif params[:discussion_participant].present?
        DiscussionParticipant.new(creation_params)
      end
    end
  end

  def enforce_policy
    authorize_action!(discussion_participant: discussion_participant)
  end
end
