# Serves as the API for invite_queues
class InviteQueuesController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can(:manage_invitations, task)
    invite_queue = InviteQueue.create(invite_queue_params)
    respond_with(invite_queue)
  end

  private

  def invite_queue_params
    params
      .require(:invite_queue)
      .permit(:queue_title,
        :main_queue,
        :task_id,
        :primary_id,
        :decision_id)
  end

  def task
    @task ||= Task.find(invite_queue_params[:task_id])
  end
end
