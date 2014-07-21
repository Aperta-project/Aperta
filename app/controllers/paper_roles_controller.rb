class CollaboratorsController < ApplicationController
  #TODO: enforce that policy
  #
  before_action :authenticate_user!
  respond_to :json

  def create
    respond_with PaperRole.create(collaborator_params.merge(role: 'collaborator'))
  end

  def destroy
    respond_with PaperRole.find(params[:id]).destroy
  end

  private

  def collaborator_params
    params.require(:collaborator).permit(:paper_id, :user_id)
  end
end
