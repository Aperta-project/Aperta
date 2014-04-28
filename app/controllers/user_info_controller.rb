class UserInfoController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def dashboard
    render json: {}, serializer: DashboardSerializer
  end
end

