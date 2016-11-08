class TasksController < ApplicationController
  before_action :authenticate_user!

  before_action :unmunge_empty_arrays, only: [:update]

  respond_to :json

  ## /paper/tasks/
  def index
    requires_user_can :view, paper
    tasks = current_user.filter_authorized(
      :view,
      paper.tasks.includes(:paper),
      participations_only: false
    ).objects

    respond_with tasks, each_serializer: TaskSerializer
  end

  def show
    requires_user_can :view, task
    respond_with(task, location: task_url(task))
  end

  def create
    requires_user_can :manage_workflow, paper
    respond_with(task, location: task_url(task))
  end

  def update
    requires_user_can :edit, task

    task.assign_attributes(task_params(task.class))
    task.save!

    Activity.task_updated! task, user: current_user

    task.after_update
    render task.update_responder.new(task, view_context).response
  end

  def destroy
    requires_user_can :manage_workflow, paper
    task.destroy
    respond_with(task)
  end

  def send_message
    requires_user_can :edit, task
    users = User.where(id: task_email_params[:recipients])
    users.each do |user|
      GenericMailer.delay.send_email(
        subject: task_email_params[:subject],
        body: task_email_params[:body],
        to: user.email
      )
    end
    head :no_content
  end

  def nested_questions
    requires_user_can :view, task
    respond_with task.nested_questions,
                 each_serializer: NestedQuestionSerializer,
                 root: "nested_questions"
  end

  def nested_question_answers
    requires_user_can :view, task
    respond_with task.nested_question_answers,
                 each_serializer: NestedQuestionAnswerSerializer,
                 root: "nested_question_answers"
  end

  private

  def paper
    paper_short_doi = params[:paper_short_doi] ||
      params.dig(:task, :paper_short_doi)
    return @paper ||= Paper.find_by_short_doi(paper_short_doi) \
      if paper_short_doi
    paper_id = params[:task][:paper_id]
    unless paper_id
      task = Task.find(params[:id] || params[:task_id])
      paper_id = task.paper_id
    end
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
    paper = Paper.find(params[:task][:paper_id])
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
end
