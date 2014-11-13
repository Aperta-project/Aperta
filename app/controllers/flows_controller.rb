class FlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  def index
    render json: current_user.flows, each_serializer: policy.serializer
  end

  def create
    if flow
      flow.save!
      render json: flow
    else
      head :bad_request
    end
  end

  def destroy
    if flow
      flow.destroy
      head :no_content
    else
      head :forbidden
    end
  end

  def authorization
    head 204 # authorization check is performed against the policy
  end

  private

  def flow
    @flow ||= begin
      if params[:id].present?
        current_user.flows.find_by(id: params[:id])
      else
        current_user.flows.build(Flow.templates[flow_params[:title].downcase])
      end
    end
  end

  def flow_params
    params.require(:flow).permit(:empty_text, :title)
  end

  def policy
    ApplicationPolicy.find_policy(self.class, current_user)
  end
end
