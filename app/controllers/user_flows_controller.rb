class UserFlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def index
    render json: current_user.flows, each_serializer: policy_serializer
  end

  def show
    respond_with UserFlow.find(params[:id]), serializer: policy_serializer
  end

  def create
    flow = current_user.flows.create! flow_template
    render json: flow
  end

  def update
    flow = UserFlow.find(params[:id])
    flow.update! flow_template
    render json: flow
  end

  def destroy
    flow = current_user.flows.find(params[:id])
    flow.destroy
    respond_with flow
  end

  def authorization
    head 204
  end

  private
  def flow_params
    params.require(:user_flow).permit(:title)
  end

  #UserFlowsPolicy sets different serializers based on permissions
  def policy_serializer
    ApplicationPolicy.find_policy(self.class, current_user).serializer
  end

  def flow_template
    FlowTemplate.template(flow_params[:title])
  end
end
