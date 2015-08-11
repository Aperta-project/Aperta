class PhasesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    paper = Paper.find(params[:phase][:paper_id])
    phase = paper.phases.create(new_phase_params)
    respond_with phase
  end

  def update
    phase = Phase.find(params[:id])
    phase.update_attributes(update_phase_params)
    respond_with phase
  end

  def show
    phase = Phase.find(params[:id])
    respond_with phase
  end

  def destroy
    phase = Phase.find(params[:id])
    if phase.tasks.empty? && phase.destroy
      render json: true
    else
      render :nothing => true, :status => 400
    end
  end

  # phase / task
  def move_task_to_phase
    # todo: add strong params
    # todo: add policies
    phase = Phase.find(params[:id])
    task = Task.find(params[:task_id])
    phase.transaction do
      # the task isn't part of the phase yet.
      # the phase.task_positions includes that task id.
      # therefore the validation on phase fails.
      # but we wanted to be able to roll back the two pieces together. :'(
      task.update!(phase: phase)
      phase.update!(task_positions: move_tasks_params[:task_positions])
      if phase.task_positions.count != phase.tasks.count
        raise ActiveRecord::Rollback.new("phase.tasks and phase.task_positions are out of sync")
      end
    end

    head :no_content
  rescue => ex
    Rails.logger.fatal "MOVE TASK TO PHASE HAS FAILED! binding.remote_pry ACTIVATE!"
    binding.remote_pry
  end

  private

  def new_phase_params
    params.require(:phase).permit(:name, :position)
  end

  def update_phase_params
    params.require(:phase).permit(:name, task_positions: [])
  end

  def move_tasks_params
    params.permit(task_positions: [])
  end
end
