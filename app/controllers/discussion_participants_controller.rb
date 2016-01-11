class DiscussionParticipantsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    discussion_participant.save
    topic_id = creation_params[:discussion_topic_id]
    UserMailer.notify_mention_in_discussion(discussion_participant.id, topic_id)
      .deliver_later
    respond_with discussion_participant
  end

  def destroy
    discussion_participant.destroy
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
