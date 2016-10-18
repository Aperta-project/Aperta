# Serves as the API for invitations
class InvitationsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    invitations = current_user.invitations_from_latest_revision
    respond_with(invitations, each_serializer: InvitationIndexSerializer)
  end

  def show
    fail AuthorizationError unless invitation.can_be_viewed_by?(current_user)
    respond_with invitation
  end

  def update
    requires_user_can(:manage_invitations, invitation.task)
    invitation.update_attributes(invitation_update_params)
    respond_with invitation
  end

  # non restful route for drag and drop changes
  def update_position
    # you'll get an invite and a new position from the params,
    # then call invite's invite_queue's move_position or whatever.
    #
    # You'll need to eventually return both the updated invite AND
    # the rest of the invites in the queue

  end
  #
  # non restful route for assigning and unassigning primaries
  def update_primary
    # you'll get an invite and a new position from the params,
    # then call invite's invite_queue's update_primary or whatever.
    #
    # You'll need to eventually return both the updated invite AND
    # the rest of the invites in the queue
    #
    if params[:primary_id]
      new_primary = Invitation.find(params[:primary_id])
      invitation.invite_queue.assign_primary(primary: new_primary, invite: invitation)
    else
      invitation.invite_queue.unassign_primary(invitation)
    end

    render json: invitation.invite_queue.invitations
  end

  # it's not a great example, but the authors controller has examples of updating 
  # the order of the author list. look at author_list_item

  def destroy
    requires_user_can(:manage_invitations, invitation.task)
    unless invitation.pending?
      invitation.errors.add(
        :invited,
        "This invitation has been sent and must be rescinded."
      )
      fail ActiveRecord::RecordInvalid, invitation
    end

    invitation.invite_queue.remove_invite(invitation)
    invitation.destroy!

    render json: invitations_in_queue
  end

  def send_invite
    requires_user_can(:manage_invitations, invitation.task)
    send_and_notify(invitation)
    render json: invitation
  end

  def create
    requires_user_can(:manage_invitations, task)
    invitation = task.invitations.build(
      invitation_params.merge(inviter: current_user)
    )

    invite_queue = task.active_invite_queue
    invite_queue.add_invite(invitation)

    if invitation_params[:state] == 'pending'
      invitation.set_invitee
      invitation.save
    else
      send_and_notify(invitation)
    end

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
    fail AuthorizationError unless invitation.invitee == current_user
    invitation.actor = current_user
    invitation.accept!
    Activity.invitation_accepted!(invitation, user: current_user)
    render json: invitation
  end

  def decline
    fail AuthorizationError unless invitation.invitee == current_user
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

  def invitations_in_queue
    invitation.invite_queue.invitations.reorder(id: :desc)
  end

  def send_and_notify(invitation)
    invitation.invite_queue.send_invite(invite)
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
      .permit(:body, :email)
  end

  def task
    @task ||= Task.find(params[:invitation][:task_id])
  end

  def invitation
    @invitation ||= Invitation.find(params[:id])
  end
end
