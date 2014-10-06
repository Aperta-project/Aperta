class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  before_action :verify_admin!, except: [:show, :update]
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def update
    task = Task.find(params[:id])
    if task
      unmunge_empty_arrays!(:task, task.array_attributes)

      notify_new_task_participant(task)

      # if task is assigned
      # make the user a participant too

      task.assign_attributes task_params(task)
      notify_task_assignee(task)

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
    task_type = params[:task][:type]
    sanitized_params = task_params task_type.constantize.new
    TaskFactory.build_task task_type, sanitized_params, current_user
  end

  def render_404
    head 404
  end

  def task
    Task.find(params[:id]) if params[:id]
  end

  def enforce_policy
    authorize_action!(task: task)
  end

  def assignee_changed?(task)
    task.assignee_id_changed? && task.assignee_id != current_user.id
  end

  def added_participant_id(task)
    ids = params[:task][:participant_ids].map(&:to_i)
    new_id = ids.reject { |x| task.participant_ids.include? x }.first
    current_user.id == new_id ? nil : new_id
  end

  def notify_new_task_participant(task)
    new_participant_id = added_participant_id(task) if params[:task][:participant_ids].present?
    UserMailer.delay.add_participant(current_user.id, new_participant_id, task.id) if new_participant_id
  end

  def notify_task_assignee(task)
    UserMailer.delay.assign_task(current_user.id, task.assignee_id, task.id) if assignee_changed?(task)
  end
end
