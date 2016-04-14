class UsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    user = User.find(params[:id])
    requires_user_can :view, user
    respond_with user
  end

  def index
    requires_user_can :view, current_user
    users = current_user
      .filter_authorized(:view, User.all.includes(:affiliations))
      .objects
    render users
  end

  def update_avatar
    if DownloadAvatar.call current_user, params[:url]
      render json: {avatar_url: current_user.avatar.url}
    else
      head 500
    end
  end
end
