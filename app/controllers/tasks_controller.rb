class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin!, except: [:show, :update]

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

  def destroy
    task = PaperPolicy.new(params[:paper_id], current_user).tasks_for_paper(params[:id]).first
    if task && task.destroy
      render json: true
    else
      render status: 400
    end
  end

  def new
    render json: { one: 1, two: [1, 2] }
  end

  private

  def task_params(task = nil)
    attributes = [:assignee_id, :completed, :title, :body, :phase_id]
    attributes += task.class::PERMITTED_ATTRIBUTES if task
    params.require(:task).permit(*attributes)
  end
end
