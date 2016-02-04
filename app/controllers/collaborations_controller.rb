# End-point for adding and removing collaborators on a paper
class CollaborationsController < ApplicationController
  before_action :authenticate_user!
  before_action :must_be_able_to_edit_paper
  respond_to :json

  def create # rubocop:disable Metrics/MethodLength
    collaboration = paper.add_collaboration(collaborator)
    Activity.collaborator_added!(collaboration, user: current_user)
    UserMailer.delay.add_collaboration(
      current_user.id,
      collaboration.user_id,
      paper.id
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

  def must_be_able_to_edit_paper
    fail AuthorizationError unless current_user.can?(:edit, paper)
  end
end
