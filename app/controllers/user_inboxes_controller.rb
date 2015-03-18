class UserInboxesController < ApplicationController
  include ActivityNotifier

  before_action :authenticate_user!

  respond_to :json

  def index
    broadcast_activities(collapser.latest_activities)
    collapser.discard!
    head :no_content
  end

  def destroy
    inbox.remove(params[:id])
    head :no_content
  end

  private

  def collapser
    @collapser ||= Notifications::Collapser.new(user: current_user, event_names: user_inbox_params[:event_names])
  end

  def inbox
    @inbox ||= Notifications::UserInbox.new(current_user.id)
  end

  def user_inbox_params
    params.permit(event_names: [])
  end
end
