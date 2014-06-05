class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def index
    render json: current_user.flows, each_serializer: FlowSerializer
  end

  def create
    flow = current_user.flows.create! Flow.templates[flow_params[:title].downcase]
    render json: flow
  end

  def destroy
    flow = current_user.flows.where(id: params[:id]).first
    if flow
      flow.destroy
      head :no_content
    else
      head :forbidden
    end
  end

  private
  def flow_params
    params.require(:flow).permit(:empty_text, :title)
  end
end
