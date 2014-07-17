class UserRolesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    render json: [UserRole.find_by(user_id: params[:user_id], role_id: params[:role_id])],
      each_serializer: UserRoleSerializer
  end

  def create
    respond_with UserRole.create! user_role_params
  end

  def destroy
    respond_with UserRole.find(params[:id]).destroy!
  end

  private

  def user_role_params
    params.require(:user_role).permit :user_id, :role_id
  end
end
