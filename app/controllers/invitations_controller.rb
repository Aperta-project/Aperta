class InvitationsController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    invitations = current_user.invitations_from_latest_revision
    respond_with(invitations, each_serializer: InvitationIndexSerializer)
  end

  def show
    respond_with invitation
  end

  def create
    requires_user_can(:manage_invitations, task)
    invitation = task.invitations.build(invitation_params)
    invitation.invite!
    Activity.invitation_created!(invitation, user: current_user)
    respond_with(invitation)
  end

  def destroy
    task = invitation.task
    requires_user_can(:manage_invitations, task)
    invitation.destroy
    Activity.invitation_withdrawn!(invitation, user: current_user)
    respond_with(invitation)
  end

  def accept
    fail AuthorizationError unless invitation.invitee == current_user
    invitation.actor = current_user
    invitation.accept!
    Activity.invitation_accepted!(invitation, user: current_user)
    respond_with(invitation)
  end

  def reject
    fail AuthorizationError unless invitation.invitee == current_user
    invitation.actor = current_user
    invitation.reject!
    Activity.invitation_rejected!(invitation, user: current_user)
    respond_with(invitation)
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email, :task_id, :invitee_id, :actor_id, :body)
  end

  def task
    @task ||= Task.find(params[:invitation][:task_id])
  end

  def invitation
    @invitation ||= Invitation.find(params[:id])
  end
end
