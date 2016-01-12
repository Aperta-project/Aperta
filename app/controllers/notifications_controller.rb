class NotificationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json
  # no enforce_policy! check since all actions are scoped to current_user

  def destroy
    notifications = current_user.notifications.where(id: params[:ids])
    notifications.destroy_all
    head :no_content
  end

  def index
    respond_with current_user.notifications
  end

  def show
    respond_with current_user.notifications.find(params[:id])
  end
end
