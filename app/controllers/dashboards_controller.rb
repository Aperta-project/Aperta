class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def show
    render json: [{}], each_serializer: DashboardSerializer, page_number: params[:page_number].to_i
  end
end
