class InvitationsController < ApplicationController

  before_action :authenticate_user!

  def create
    invitation = task.invitations.create(invitation_params)
    render json: invitation, status: :created
  end

  def update
    invitation.update(invitation_params.merge!(actor_id: current_user.id))
    render json: nil, status: :no_content
  end


  private

  def invitation_params
    params.require(:invitation).permit(:email, :task_id, :invitee_id, :actor_id, :state)
  end

  def task
    @task ||= Task.find(params[:invitation][:task_id])
  end

  def invitation
    @invitation ||= Invitation.find(params[:id])
  end

end
