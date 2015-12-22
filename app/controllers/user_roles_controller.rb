class UserRolesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  # TODO: look into this
  def index
    render json: [UserRole.find_by(user_id: params[:user_id],
                                   old_role_id: params[:old_role_id])],
           each_serializer: UserRoleSerializer
  end

  def create
    user_role.save!
    respond_with user_role
  end

  def destroy
    user_role.destroy!
    respond_with user_role
  end

  private

  def user_role_params
    params.require(:user_role).permit :user_id, :old_role_id
  end

  def user_role
    id = params[:id]
    @user_role ||= begin
      if id.present?
        UserRole.find(id)
      else
        UserRole.new(user_role_params)
      end
    end
  end

  def enforce_policy
    authorize_action!(resource: user_role)
  end
end
