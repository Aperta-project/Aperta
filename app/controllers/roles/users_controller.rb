module Roles
  class UsersController < ApplicationController
    def index
      role = Role.find(params[:role_id])
      authorize_action! journal: role.journal

      render json: role.users
    end
  end
end
