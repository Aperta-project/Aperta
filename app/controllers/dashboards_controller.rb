class DashboardsController < ApplicationController

  before_action :authenticate_user!

  def show
    render json: [{}], each_serializer: DashboardSerializer
  end
end
