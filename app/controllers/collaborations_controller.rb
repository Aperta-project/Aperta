class CollaborationsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    paper_role = PaperRole.create(collaborator_params.merge(role: PaperRole::COLLABORATOR))
    UserMailer.delay.add_collaborator(current_user, User.find(collaborator_params[:user_id]), paper) if paper_role.valid?
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
    @paper ||= if params[:id] # only the collaboration's id is posted to destroy
                 PaperRole.find(params[:id]).paper
               elsif params[:collaboration] # during create all the params are present
                 Paper.find(collaborator_params[:paper_id])
               end
  end

  def enforce_policy
    authorize_action!(paper: paper)
  end
end
