class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def show
    respond_with flow
  end

  # TODO see if this can be simplified.
  def create
    flow.assign_attributes(title: formatted_title)
    flow.save!
    render json: flow
  end

  def update
    flow.update!(title: formatted_title)
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
    params.require(:flow).permit(:title, :role_id)
  end

  def formatted_title
    flow_params[:title].downcase.capitalize
  end

  def enforce_policy
    authorize_action!(resource: flow)
  end
end
