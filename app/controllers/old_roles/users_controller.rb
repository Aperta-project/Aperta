module OldRoles
  class UsersController < ApplicationController
    before_action :authenticate_user!

    def index
      old_role = OldRole.find(params[:old_role_id])
      authorize_action! journal: old_role.journal

      render json: old_role.users
    end
  end
end
