class NotificationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json
  # no enforce_policy! check since all actions are scoped to current_user

  def destroy
    notification = current_user.find(params[:id]).destroy
    respond_with notification
  end

  def index
    respond_with current_user.notifications
  end
end
