class UserFlowsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def index
    render json: current_user.flows, meta: potential_user_flow_titles
  end

  def show
    respond_with UserFlow.find(params[:id])
  end

  def create
    flow = current_user.flows.create!(title: formatted_title)
    render json: flow
  end

  def update
    flow = UserFlow.find(params[:id])
    flow.update!(title: formatted_title)
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

  def formatted_title
    flow_params[:title].downcase.capitalize
  end

  def potential_user_flow_titles
    { titles: RoleFlow.joins(role: :users).where(users: { id: current_user.id }).uniq.pluck(:title) }
  end
end
