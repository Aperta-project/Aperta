class InvitationsController < ApplicationController
  before_action :authenticate_user!

  def create
    invitation = task.invitations.create(invitation_params)
    invitation.invite!
    render json: invitation, status: :created
  end

  def destroy
    invitation.destroy
    render json: nil, status: :no_content
  end

  def accept
    invitation.actor = current_user
    invitation.accept!
    render json: nil, status: :no_content
  end

  def reject
    invitation.actor = current_user
    invitation.reject!
    render json: nil, status: :no_content
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
