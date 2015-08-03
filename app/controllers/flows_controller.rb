class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index]
  respond_to :json

  def index
    role = Role.find(params[:role_id])
    role_policy = RolesPolicy.new(current_user: current_user, journal: role.journal, role: role)

    if role_policy.show?
      respond_with role.flows
    else
      head 403
    end
  end

  def show
    respond_with flow
  end

  def create
    flow.assign_attributes(title: formatted_title)
    flow.save!
    render json: flow
  end

  def update
    flow.update!(flow_params)
    render json: flow
  end

  def destroy
    flow.destroy
    respond_with flow
  end

  private

  def role
    @role ||= Role.find(flow_params[:role_id])
  end

  def flow
    @flow ||= begin
      if params[:id].present?
        Flow.find(params[:id])
      else
        role.flows.new(flow_params)
      end
    end
  end

  def flow_params
    params.require(:flow).permit(:title, :role_id, query: [:type, :state, :assigned, :role])
  end

  def formatted_title
    flow_params[:title].downcase.capitalize
  end

  def enforce_policy
    authorize_action!(resource: flow)
  end
end
