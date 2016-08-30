class UsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can(:manage_user, Journal)
    render json: User.find(params[:id])
  end

  def update_avatar
    if DownloadAvatar.call current_user, params[:url]
      render json: {avatar_url: current_user.avatar.url}
    else
      head 500
    end
  end
end
