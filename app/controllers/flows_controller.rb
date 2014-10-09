class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  def index
    render json: current_user.flows, each_serializer: policy.serializer
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

  def policy
    ApplicationPolicy.find_policy(self.class, current_user)
  end
end
