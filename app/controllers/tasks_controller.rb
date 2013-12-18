class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!, except: :update

  def index
    @paper = Paper.find(params[:id])
    @task_manager = @paper.task_manager
  end

  def update
    task = if current_user.admin?
             Task.where(id: params[:id]).first
           else
             current_user.tasks.where(id: params[:id]).first
           end
    if task
      task.update task_params(task)
      head :no_content
    else
      head :forbidden
    end
  end

  private

  def task_params(task = nil)
    attributes = [:assignee_id, :completed]
    attributes += task.class::PERMITTED_ATTRIBUTES if task
    params.require(:task).permit(*attributes)
  end
end
