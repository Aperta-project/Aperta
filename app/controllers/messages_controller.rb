class MessageTasksController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    # Parameters: {
    # "message_task"=>{"title"=>"title", "type"=>"MessageTask",
    # "completed"=>false, "role"=>nil, "body"=>"body", "phase_id"=>"17",
    # "assignee_id"=>nil}
    # }
    message_task = params[:message_task]
    # then put in the appropriate shiat.
    if current_user.admin
      paper = Paper.find(params[:paper_id])
    else
      paper = current_user.managed_papers.find(params[:paper_id])
    end
    phase = paper.phases.find(params[:phase_id])
    message_task = MessageTaskCreator.with_initial_comment(phase,
                                                           message_task_params,
                                                           current_user)
    render json: message_task
  end

 private

  def message_task_params
    params.require(:message_task).permit([:message_body, :message_subject, {participant_ids: []}])
  end

  def render_404
    head 404
  end
end
