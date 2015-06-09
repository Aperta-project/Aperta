module Roles
  class UsersController < ApplicationController
    before_action :authenticate_user!

    def index
      role = Role.find(params[:role_id])
      authorize_action! journal: role.journal

      render json: role.users
    end
  end
end
