# Serves as the API for invitations
class InvitationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    invitations = current_user.invitations_from_latest_revision
    respond_with(invitations, each_serializer: InvitationIndexSerializer)
  end

  def show
    raise AuthorizationError unless invitation.can_be_viewed_by?(current_user)
    respond_with invitation
  end

  def update
    requires_user_can(:manage_invitations, invitation.task)
    invitation.update_attributes!(invitation_update_params)
    respond_with invitation
  end

  # non restful route for drag and drop changes
  def update_position
    requires_user_can(:manage_invitations, invitation.task)
    invitation.invitation_queue.move_invitation_to_position(
      invitation, params[:position]
    )

    render json: invitations_in_queue
  end

  # non restful route for assigning and unassigning primaries
  def update_primary
    requires_user_can(:manage_invitations, invitation.task)
    if params[:primary_id].present?
      new_primary = Invitation.find(params[:primary_id])
      invitation.invitation_queue.assign_primary(
        primary: new_primary,
        invitation: invitation
      )
    else
      invitation.invitation_queue.unassign_primary_from(invitation)
    end

    render json: invitations_in_queue
  end

  def destroy
    requires_user_can(:manage_invitations, invitation.task)
    unless invitation.pending?
      invitation.errors.add(
        :invited,
        "This invitation has been sent and must be rescinded."
      )
      raise ActiveRecord::RecordInvalid, invitation
    end

    queue = invitation.invitation_queue
    queue.destroy_invitation(invitation)

    render json: invitations_in_queue(queue)
  end

  def send_invite
    requires_user_can(:manage_invitations, invitation.task)
    send_and_notify(invitation)
    render json: invitations_in_queue
  end

  def create
    requires_user_can(:manage_invitations, task)
    @invitation = task.invitations.build(
      invitation_params.merge(inviter: current_user)
    )
    invitation_queue = task.active_invitation_queue
    invitation_queue.add_invitation(invitation)

    @invitation.set_invitee
    @invitation.save

    render json: invitations_in_queue
  end

  def rescind
    task = invitation.task
    requires_user_can(:manage_invitations, task)
    invitation.rescind!
    Activity.invitation_withdrawn!(invitation, user: current_user)
    render json: invitation
  end

  def accept
    raise AuthorizationError unless invitation.invitee == current_user
    invitation.actor = current_user
    invitation.accept!
    Activity.invitation_accepted!(invitation, user: current_user)
    render json: invitation
  end

  def decline
    raise AuthorizationError unless invitation.invitee == current_user
    invitation.update_attributes(
      actor: current_user,
      decline_reason: invitation_params[:decline_reason],
      reviewer_suggestions: invitation_params[:reviewer_suggestions]
    )
    invitation.decline!
    Activity.invitation_declined!(invitation, user: current_user)
    render json: invitation
  end

  private

  def invitations_in_queue(queue = nil)
    invitations = if queue
                    queue.invitations
                  else
                    invitation.invitation_queue.invitations
                  end

    invitations
      .reorder(id: :desc)
      .includes(
        :task,
        :invitee,
        :primary,
        :alternates,
        :invitation_queue,
        :attachments)
  end

  def send_and_notify(invitation)
    invitation.invitation_queue.send_invitation(invitation)
    Activity.invitation_sent!(invitation, user: current_user)
  end

  def invitation_params
    params
      .require(:invitation)
      .permit(:actor_id,
        :body,
        :decline_reason,
        :decision_id,
        :email,
        :state,
        :reviewer_suggestions,
        :task_id)
  end

  def invitation_update_params
    params
      .require(:invitation)
      .permit(:id, :body, :email)
  end

  def task
    @task ||= Task.find(params[:invitation][:task_id])
  end

  def invitation
    @invitation ||= Invitation.find(params[:id])
  end
end
