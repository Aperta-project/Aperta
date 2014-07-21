class CollaborationsController < ApplicationController
  #TODO: enforce that policy
  #
  before_action :authenticate_user!
  respond_to :json

  def create
    paper_role = PaperRole.create(collaborator_params.merge(role: 'collaborator'))
    render status: 201, json: paper_role, serializer: CollaborationSerializer
  end

  def destroy
    respond_with PaperRole.find(params[:id]).destroy, serializer: CollaborationSerializer
  end

  private

  def collaborator_params
    params.require(:collaboration).permit(:paper_id, :user_id)
  end
end
