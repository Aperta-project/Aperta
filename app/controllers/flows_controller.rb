class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def index
    render json: FlowManagerData.new(current_user).flows, each_serializer: FlowSerializer
  end

  def destroy
    flow = current_user.user_settings.flows.where(id: params[:id]).first
    if flow
      flow.destroy
      head :ok
    else
      head :forbidden
    end
  end
end
