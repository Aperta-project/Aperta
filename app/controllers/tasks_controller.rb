class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:create]
  before_action :enforce_policy_on_create, only: [:create]
  before_action :verify_admin!, except: [:show, :update]
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def update
    task = Task.find(params[:id])
    if task
      unmunge_empty_arrays!(:task, task.array_attributes)

      task.assign_attributes task_params(task)
      task.save!

      render task.update_responder.new(task, view_context).response
    else
      head :forbidden
    end
  end

  def index
    respond_with Task.find(params[:ids])
  end

  def create
    task = build_task
    if task.persisted?
      respond_with task, location: task_url(task)
    else
      render json: { errors: task.errors }, status: :unprocessable_entity
    end
  end

  def show
    @task = Task.find(params[:id])
    respond_to do |f|
      f.json { render json: @task }
      f.html { render 'ember/index' , layout: 'ember'}
    end
  end

  def destroy
    task_temp = Task.find(params[:id])
    task = PaperQuery.new(task_temp.paper, current_user).tasks_for_paper(params[:id]).first
    if task
      task.destroy
      respond_with task
    end
  end

  private

  def task_params(task)
    attributes = task.permitted_attributes
    params.require(:task).permit(*attributes).tap do |whitelisted|
      whitelisted[:body] = params[:task][:body] || []
    end
  end

  def build_task
    task_klass = TaskType.constantize!(params[:task][:type])
    sanitized_params = task_params(task_klass.new)
    TaskFactory.build_task(task_klass, sanitized_params, current_user)
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(task: Task.find(params[:id]))
  end

  def enforce_policy_on_create
    task_type = params[:task][:type]
    sanitized_params = task_params task_type.constantize.new

    authorize_action!(task: Task.new(sanitized_params))
  end
end
