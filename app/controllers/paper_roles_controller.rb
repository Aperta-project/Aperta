class PaperRolesController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def index
    render json: paper.journal.roles, each_serializer: RoleSerializer, root: "roles"
  end

  private

  def enforce_policy
    authorize_action! paper: paper
  end

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end
end
