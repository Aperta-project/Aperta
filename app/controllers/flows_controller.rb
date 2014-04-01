class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def index
    render json: FlowManagerData.new(current_user).flows, each_serializer: FlowSerializer
  end
end
