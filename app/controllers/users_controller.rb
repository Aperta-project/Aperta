class UsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    respond_with User.find(params[:id])
  end

  def index
    render json: User.all.includes(:affiliations)
  end

  def update_avatar
    if DownloadAvatar.call current_user, params[:url]
      render json: {avatar_url: current_user.avatar.url}
    else
      head 500
    end
  end
end
