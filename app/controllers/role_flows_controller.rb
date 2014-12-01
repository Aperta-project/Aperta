class RoleFlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def show
    respond_with role_flow
  end

  def create
    role_flow.assign_attributes(title: formatted_title)
    role_flow.save!
    render json: role_flow
  end

  def update
    role_flow.update!(title: formatted_title)
    render json: role_flow
  end

  def destroy
    role_flow.destroy
    respond_with role_flow
  end

  private

  def role
    @role ||= Role.find(flow_params[:role_id])
  end

  def role_flow
    @role_flow ||= begin
      if params[:id].present?
        RoleFlow.find(params[:id])
      else
        role.flows.new(flow_params)
      end
    end
  end

  def flow_params
    params.require(:role_flow).permit(:title, :role_id)
  end

  def formatted_title
    flow_params[:title].downcase.capitalize
  end

  def enforce_policy
    authorize_action!(resource: role_flow)
  end
end
