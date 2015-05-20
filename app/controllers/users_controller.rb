class UsersController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    respond_with User.find(params[:id])
  end

  def index
    render json: User.all.includes(:affiliations)
  end

  def reset
    head :ok if current_user.send_reset_password_instructions
  end

  def update_avatar
    if DownloadAvatar.call current_user, params[:url]
      render json: {avatar_url: current_user.avatar.url}
    else
      head 500
    end
  end
end
