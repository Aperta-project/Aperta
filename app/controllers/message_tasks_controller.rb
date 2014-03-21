class MessageTasksController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def create
    # paper_id, phase_id, 
    # { paper_id: id, phase_id: id, task: {message_body: "body", task_title: "title", participant_ids [1,2,3]}
    # params.require(:task).permit([:message_body, :message_subject, {participant_ids: []}])
    if current_user.admin
      paper = Paper.find(params[:paper_id])
    else
      paper = current_user.managed_papers.find(params[:paper_id])
    end
    phase = paper.phases.find(params[:phase_id])
    message_task = MessageTaskCreator.with_initial_comment(phase,
                                                           message_task_params,
                                                           current_user)
    respond_with MessageTaskPresenter.for(message_task).data_attributes, location: task_path(message_task)
  end

  def update_participants
    task = Task.find(params[:id])
    p = PaperPolicy.new task.paper, current_user
    if p.paper
      task.update_attributes! update_participants_params
      @users = task.participants
      respond_to do |f|
        f.json { render "user_info/thumbnails" }
      end
    else
      head 404
    end
  end

 private

  def message_task_params
    params.require(:task).permit([:message_body, :message_subject, {participant_ids: []}])
  end

  def update_participants_params
    params.require(:task).permit({participant_ids: []})
  end



  def render_404
    head 404
  end

end
