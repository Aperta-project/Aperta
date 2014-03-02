class UserInfoController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def thumbnails
    @users = User.all
    render "user_info/thumbnails.json.jbuilder"
  end
end
