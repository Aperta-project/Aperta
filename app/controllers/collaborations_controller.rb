# End-point for adding and removing collaborators on a paper
class CollaborationsController < ApplicationController
  before_action :authenticate_user!
  before_action do
    fail AuthorizationError unless
      current_user.can?(:manage_collaborators, paper)
  end
  respond_to :json

  def create
    collaboration = paper.add_collaboration(collaborator)
    Activity.collaborator_added!(collaboration, user: current_user)
    UserMailer.delay.add_collaborator(
      current_user.id,
      collaboration.user_id,
      paper.id
    )

    # This only exists to preserve sending events to the new collaborator
    # thru the event stream about a paper they have access to.
    PaperRole.create!(
      collaborator_params.merge(old_role: PaperRole::COLLABORATOR)
    )

    respond_with(
      collaboration,
      serializer: CollaborationSerializer,
      location: nil
    )
  end

  def destroy
    collaboration = paper.remove_collaboration(params[:id])
    Activity.collaborator_removed!(collaboration, user: current_user)

    # This only exists to preserve sending events to the collaborator's
    # browser thru the event stream so the paper is removed
    PaperRole.where(
      user_id: collaboration.user_id,
      paper_id: collaboration.assigned_to_id,
      old_role: PaperRole::COLLABORATOR
    ).destroy_all

    respond_with collaboration, serializer: CollaborationSerializer
  end

  private

  def collaborator
    @collaborator ||= User.find(collaborator_params[:user_id])
  end

  def collaborator_params
    params.require(:collaboration).permit(:paper_id, :user_id)
  end

  def paper
    @paper ||= begin
      # only the collaboration's id is posted to destroy
      if params[:id]
        Assignment.find(params[:id]).assigned_to
      elsif params[:collaboration]
        # during create all the params are present
        Paper.find(collaborator_params[:paper_id])
      end
    end
  end
end
