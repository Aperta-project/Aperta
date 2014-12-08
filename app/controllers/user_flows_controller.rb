class UserFlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def index
    render json: current_user.user_flows, meta: potential_user_flow_titles
  end

  def show
    respond_with UserFlow.find(params[:id])
  end

  def create
    user_flows = current_user.user_flows.create!(title: formatted_title)
    render json: user_flows
  end

  def update
    user_flow = UserFlow.find(params[:id])
    user_flow.flow.update!(title: formatted_title)
    render json: user_flow
  end

  def destroy
    user_flows = current_user.user_flows.find(params[:id])
    user_flows.destroy
    respond_with user_flows
  end

  def authorization
    head 204
  end

  private
  def flow_params
    params.require(:user_flow).permit(:title)
  end

  def formatted_title
    flow_params[:title].downcase.capitalize
  end

  def potential_user_flow_titles
    { titles: Flow.joins(role: :users).where(users: { id: current_user.id }).uniq.pluck(:title) }
  end
end
