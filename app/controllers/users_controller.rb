class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    render json: current_user
  end

  def update
    current_user.avatar = params[:profile][:avatar].first
    if current_user.save
      render json: {image_url: current_user.avatar.url}
    else
      head 500
    end
  end
end
