class DiscussionParticipantsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can :add_participant, discussion_participant.discussion_topic
    discussion_participant.save
    respond_with discussion_participant
  end

  # TODO: add permission
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
end
