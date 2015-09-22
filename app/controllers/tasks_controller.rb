class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:index, :questions, :comments, :participations]

  before_action :unmunge_empty_arrays, only: [:update]

  respond_to :json

  ## /paper/tasks/
  def index
    respond_with(Task.joins(:paper).includes([{paper: [:journal, :creator]}, :participations]).where('papers.id = ?', params[:paper_id]))
  end

  def show
    respond_with(task, location: task_url(task))
  end

  def create
    task.save
    respond_with(task, location: task_url(task))
  end

  def update
    unless task.allow_update?
      task.paper.errors.add(:editable, "This paper cannot be edited at this time.")
      raise ActiveRecord::RecordInvalid, task.paper
    end

    task.assign_attributes(task_params(task.class))
    task.save!

    Activity.task_updated! task, user: current_user

    task.send_emails if task.respond_to?(:send_emails)
    task.after_update
    render task.update_responder.new(task, view_context).response
  end

  def destroy
    task.destroy
    respond_with(task)
  end

  def send_message
    AdhocMailer.delay.send_adhoc_email(
      task_email_params[:subject],
      task_email_params[:body],
      task_email_params[:recipients]
    )
    head :ok
  end

  def attachments
    respond_with task.attachments
  end

  def comments
    respond_with task.comments, root: :comments
  end

  def participations
    respond_with task.participations, root: :participations
  end

  def questions
    respond_with task.questions, root: :questions
  end

  private

  def paper
    @paper ||= Paper.find(params[:paper_id])
  end

  def task
    @task ||= begin
      if params[:id].present?
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

  def enforce_policy
    authorize_action!(task: task)
  end
end
