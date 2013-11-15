class Admin::UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.all
  end

  def update
    @user = User.find(params[:id])

    if @user.update user_params
      respond_to do |f|
        f.html { redirect_to root_path }
        f.json { head :no_content }
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:admin)
  end
end
