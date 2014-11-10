class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  def index
    flows = params[:ids].present? ? Flow.find(params[:ids]) : current_user.flows
    render json: flows, each_serializer: policy.serializer
  end

  def show
    respond_with Flow.find(params[:id]), serializer: policy.serializer
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

  def authorization
    head 204
  end

  private
  def flow_params
    params.require(:flow).permit(:empty_text, :title)
  end

  def policy
    ApplicationPolicy.find_policy(self.class, current_user)
  end
end
