class FlowManagersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def show
    render json: FlowManagerData.new(current_user).flows
  end
end
