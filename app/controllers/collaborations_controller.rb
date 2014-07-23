class CollaborationsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    paper_role = PaperRole.create(collaborator_params.merge(role: 'collaborator'))
    respond_with paper_role, serializer: CollaborationSerializer
  end

  def destroy
    respond_with PaperRole.find(params[:id]).destroy, serializer: CollaborationSerializer
  end

  private

  def collaborator_params
    params.require(:collaboration).permit(:paper_id, :user_id)
  end

  def paper
    if params[:id] # only the collaboration's id is posted to destroy
      return @paper if @paper
      collaboration = PaperRole.find(params[:id])
      @paper = collaboration.paper
    elsif params[:collaboration] # during create all the params are present
      @paper ||= Paper.find(collaborator_params[:paper_id])
    end
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end
end
