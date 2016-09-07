class TasksController < ApplicationController
  before_action :authenticate_user!

  before_action :must_be_able_to_view_paper, only: [:index]
  before_action :must_be_able_to_manage_workflow_on_paper, only: [:create, :destroy]

  before_action :must_be_able_to_view_task, only: [:show, :nested_questions, :nested_question_answers]
  before_action :must_be_able_to_edit_task, only: [:update, :send_message]

  before_action :unmunge_empty_arrays, only: [:update]

  respond_to :json

  ## /paper/tasks/
  def index
    tasks = current_user.filter_authorized(
      :view,
      paper.tasks.includes(:paper),
      participations_only: false
    ).objects

    respond_with tasks, each_serializer: TaskSerializer
  end

  def show
    respond_with(task, location: task_url(task))
  end

  def create
    respond_with(task, location: task_url(task))
  end

  def update
    requires_user_can(:edit, task)

    task.assign_attributes(task_params(task.class))
    task.save!

    Activity.task_updated! task, user: current_user

    task.after_update
    render task.update_responder.new(task, view_context).response
  end

  def destroy
    task.destroy
    respond_with(task)
  end

  def send_message
    users = User.where(id: task_email_params[:recipients])
    users.each do |user|
      AdhocMailer.delay.send_adhoc_email(
        task_email_params[:subject],
        task_email_params[:body],
        user
      )
    end
    head :no_content
  end

  def nested_questions
    respond_with task.nested_questions,
                 each_serializer: NestedQuestionSerializer,
                 root: "nested_questions"
  end

  def nested_question_answers
    respond_with task.nested_question_answers,
                 each_serializer: NestedQuestionAnswerSerializer,
                 root: "nested_question_answers"
  end

  private

  def paper
    paper_id = params[:paper_id] || params.dig(:task, :paper_id)
    paper_id ||= Task.find(params[:id] || params[:task_id]).paper.id
    @paper ||= Paper.find(paper_id)
  end

  def task
    @task ||= begin
      if params[:id].present?
        Task.find(params[:id])
      elsif params[:task_id].present?
        Task.find(params[:task_id])
      else
        TaskFactory.create(task_type, new_task_params)
      end
    end
  end

  def task_type
    Task.safe_constantize(params[:task][:type])
  end

  def new_task_params
    paper = Paper.find params[:task][:paper_id]
    task_params(task_type).merge(paper: paper, creator: paper.creator)
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

  def must_be_able_to_manage_workflow_on_paper
    fail AuthorizationError unless current_user.can?(:manage_workflow, paper)
  end

  def must_be_able_to_view_paper
    fail AuthorizationError unless current_user.can?(:view, paper)
  end

  def must_be_able_to_view_task
    fail AuthorizationError unless current_user.can?(:view, task)
  end

  def must_be_able_to_edit_task
    fail AuthorizationError unless current_user.can?(:edit, task)
  end
end
