class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!, except: [:show, :update]

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
      attributes = %w(id completed)
      render json: task.as_json.slice(*attributes)
    else
      head :forbidden
    end
  end

  def create
    task = Task.new task_params
    task.role = 'admin'
    task.save
    head :no_content
  end

  def show
    @task = Task.find(params[:id])
    respond_to do |f|
      f.json { render json: TaskPresenter.for(@task).data_attributes }
      f.html { render layout: 'overlay' }
    end
  end

  private

  def task_params(task = nil)
    attributes = [:assignee_id, :completed, :title, :body, :phase_id]
    attributes += task.class::PERMITTED_ATTRIBUTES if task
    params.require(:task).permit(*attributes)
  end
end
