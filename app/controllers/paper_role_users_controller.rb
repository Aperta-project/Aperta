class PaperRoleUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def index
    old_role = OldRole.where(id: params[:old_role_id], journal_id: paper.journal_id).first!
    render json: old_role.users, each_serializer: UserSerializer, root: "users"
  end

  private

  def enforce_policy
    authorize_action! paper: paper
  end

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end
end
