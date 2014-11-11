class RoleFlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:create]
  before_action :enforce_policy_on_create, only: [:create]
  respond_to :json

  def show
    respond_with RoleFlow.find(params[:id])
  end

  def create
    role = Role.find(flow_params[:role_id])
    flow = role.flows.create! flow_template
    render json: flow
  end

  def update
    flow = RoleFlow.find(params[:id])
    flow.update flow_template
    if flow.valid?
      render json: flow
    else
      head 422
    end
  end

  def destroy
    flow = RoleFlow.find(params[:id])
    flow.destroy
    respond_with flow
  end

  private
  def flow_params
    params.require(:role_flow).permit(:title, :role_id)
  end

  def enforce_policy
    flow = RoleFlow.find(params[:id])
    authorize_action!(journal: flow.role.journal)
  end

  def enforce_policy_on_create
    role = Role.find(flow_params[:role_id])
    authorize_action!(journal: role.journal)
  end

  def flow_template
    FlowTemplate.template(flow_params[:title])
  end
end
