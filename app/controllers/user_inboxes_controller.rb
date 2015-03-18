# used by client when an event notification has been 'dismissed'
#
class UserInboxesController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    unread_user_activities = current_user.unread_activities.with_event_names(user_inbox_params[:event_names])
    latest_activities = unread_user_activities.collapsed_most_recent
    superceded_activities = unread_user_activities.without(latest_activities)

    # remove the older activities from the user inbox
    current_user.inbox.remove(superceded_activities.pluck(:id))

    # return the newest activities
    respond_with latest_activities, each_serializer: Notifications::ActivitySerializer, root: :events
  end

  def destroy
    Notifications::UserInbox.new(current_user.id).remove(params[:id])
    head :no_content
  end

  private

  def user_inbox_params
    params.permit(event_names: [])
  end
end
