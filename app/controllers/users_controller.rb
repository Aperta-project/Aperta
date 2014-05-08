class UsersController < ApplicationController
  before_action :authenticate_user!

  def profile
    render json: current_user
  end

  def show
    # When ember goes to the profile page we want to reload the information
    # for the current user.  It's easiest to do this using aUser.reload() and having 
    # a RESTful route in rails.  however we don't want to expose all users' data.  for now
    # only return if the requested id is the current user's id.
    if params[:id] == current_user.to_param
      render json: current_user
    else
      head 404
    end
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
