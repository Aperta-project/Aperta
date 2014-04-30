class UsersController < ApplicationController
  def update
    user = current_user if params[:id].to_i == current_user.id
    user.avatar = params[:profile][:avatar].first
    if user.save
      render json: {image_url: user.avatar.url}
    else
      head 500
    end
  end
end
