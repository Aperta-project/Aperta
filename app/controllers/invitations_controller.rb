class InvitationsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    invitations = current_user.invitations_from_latest_revision
    respond_with(invitations, each_serializer: InvitationIndexSerializer)
  end

  def create
    invitation = task.invitations.create(invitation_params)
    invitation.invite!
    respond_with(invitation)
  end

  def destroy
    invitation.destroy
    respond_with(invitation)
  end

  def accept
    invitation.actor = current_user
    invitation.accept!
    respond_with(invitation)
  end

  def reject
    invitation.actor = current_user
    invitation.reject!
    respond_with(invitation)
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :task_id, :invitee_id, :actor_id)
  end

  def task
    @task ||= Task.find(params[:invitation][:task_id])
  end

  def invitation
    @invitation ||= Invitation.find(params[:id])
  end
end
