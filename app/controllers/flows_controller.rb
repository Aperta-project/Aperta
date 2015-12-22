class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index]
  respond_to :json

  def index
    old_role = OldRole.find(params[:old_role_id])
    role_policy = OldRolesPolicy.new(current_user: current_user, journal: old_role.journal, old_role: old_role)

    if role_policy.show?
      respond_with old_role.flows
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

  def old_role
    @old_role ||= OldRole.find(flow_params[:old_role_id])
  end

  def flow
    @flow ||= begin
      if params[:id].present?
        Flow.find(params[:id])
      else
        old_role.flows.new(flow_params)
      end
    end
  end

  def flow_params
    params.require(:flow).permit(:title, :old_role_id, query: [:type, :state, :assigned, :old_role])
  end

  def formatted_title
    flow_params[:title].downcase.capitalize
  end

  def enforce_policy
    authorize_action!(resource: flow)
  end
end
