class DiscussionParticipantsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can :manage_participant, discussion_topic
    discussion_topic.add_discussion_participant(discussion_participant)
    respond_with discussion_participant
  end

  def destroy
    requires_user_can :manage_participant, discussion_topic
    discussion_topic.remove_discussion_participant(discussion_participant)
    respond_with discussion_participant
  end

  private

  def creation_params
    params.require(:discussion_participant).permit(
      :discussion_topic_id,
      :user_id
    )
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

  def discussion_topic
    discussion_participant.discussion_topic
  end
end
