module Roles
  class UsersController < ApplicationController
    def index
      role = Role.find(params[:role_id])
      render json: role.users
    end
  end
end
