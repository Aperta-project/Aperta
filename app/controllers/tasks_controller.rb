class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy

  before_action :unmunge_empty_arrays, only: [:update]

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def show
    respond_to do |f|
      f.json { render json: task }
      f.html { render 'ember/index' , layout: 'ember'}
    end
  end

  def create
    if task.save
      respond_with task, location: task_url(task)
    else
      render json: { errors: task.errors }, status: :unprocessable_entity
    end
  end

  def update
    task.assign_attributes(task_params(task.class))
    task.save!
    render task.update_responder.new(task, view_context).response
  end

  def destroy
    task.destroy
    respond_with task
  end

  def send_message
    AdhocMailer.delay.send_adhoc_email(
      task_email_params[:subject],
      task_email_params[:body],
      task_email_params[:recipients],
    )
    head :ok
  end

  private


  def paper
    @paper ||= Paper.find(params[:paper_id])
  end

  def task
    @task ||= begin
      if(params[:id].present?)
        Task.find(params[:id])
      else
        task_klass = TaskType.constantize!(params[:task][:type])
        TaskFactory.build(task_klass, task_params(task_klass))
      end
    end
  end

  def unmunge_empty_arrays
    unmunge_empty_arrays!(:task, task.array_attributes)
  end

  def task_params(task_klass)
    attributes = task_klass.permitted_attributes
    params.require(:task).permit(*attributes).tap do |whitelisted|
      whitelisted[:body] = params[:task][:body] || []
    end
  end

  def task_email_params
    params.require(:task).permit(:subject, :body, recipients: []).tap do |whitelisted|
      whitelisted[:subject] ||= "No subject"
      whitelisted[:body] ||= "Nothing to see here."
      whitelisted[:recipients] ||= []
    end
  end

  def render_404
    head 404
  end

  def enforce_policy
    authorize_action!(task: task)
  end
end
