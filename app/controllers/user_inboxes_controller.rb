class UserInboxesController < ApplicationController
  include Notifications::ActivityBroadcaster

  before_action :authenticate_user!

  respond_to :json

  def index
    collapser.discard!
    render json: collapser.latest_activities
  end

  def destroy
    inbox.remove(params[:id])
    head :no_content
  end

  private

  def collapser
    @collapser ||= Notifications::Collapser.new(inbox: inbox, event_names: user_inbox_params[:event_names])
  end

  def inbox
    @inbox ||= Notifications::UserInbox.new(current_user.id)
  end

  def user_inbox_params
    params.permit(event_names: [])
  end
end
