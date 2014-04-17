class Api::UsersController < ApplicationController
  def show
    @user = User.find params[:id]
    render json: [@user], each_serializer: Api::UserSerializer
  end
end
