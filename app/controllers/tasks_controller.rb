class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!, except: [:show, :update, :update_participants]

  def index
    @paper = Paper.includes(:journal, :phases => :tasks).find(params[:id])
    respond_to do |format|
      format.html
      format.json do
        @phases = @paper.phases
      end
    end
  end

  def update
    task = if current_user.admin?
             Task.where(id: params[:id]).first
           else
             current_user.tasks.where(id: params[:id]).first
           end
    if task
      task.update task_params(task)
      render json: task
    else
      head :forbidden
    end
  end

  def create
    task = Task.new task_params
    task.role = 'admin'
    if task.save
      render json: task
    else
      render status: 500
    end
  end

  def show
    @task = Task.find(params[:id])
    respond_to do |f|
      f.json { render json: @task }
      f.html { render layout: 'overlay' }
    end
  end

  def destroy
    task_temp = Task.find(params[:id])
    task = PaperPolicy.new(task_temp.paper, current_user).tasks_for_paper(params[:id]).first
    if task && task.destroy
      render json: true
    else
      render status: 400
    end
  end

  private

  def task_params(task = nil)
    attributes = [:assignee_id, :completed, :title, :body, :phase_id]
    attributes += task.class::PERMITTED_ATTRIBUTES if task
    params.require(:task).permit(*attributes)
  end
end
