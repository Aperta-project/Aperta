class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!

  def index
    @paper = Paper.find(params[:id])
    @task_manager = @paper.task_manager
  end

  def update
    task = Task.where(id: params[:id]).first
    task.update task_params(task)
    head :no_content
  end

  private

  def task_params(task = nil)
    attributes = [:assignee_id, :completed]
    attributes += task.class::PERMITTED_ATTRIBUTES if task
    params.require(:task).permit(*attributes)
  end
end
