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

    # serialize using the base task serializer which acts as a lightweight
    # summary of each task rather than each custom task serializer that may
    # side load an excessive amount of data that is unnecessary for an index
    # response.
    respond_with tasks, each_serializer: TaskSerializer
  end

  def show
    requires_user_can :view, task
    respond_with(task, location: task_url(task))
  end

  def create
    requires_user_can :manage_workflow, paper
    if does_not_violate_single_billing_task_condition?
      @task = TaskFactory.create(task_type, new_task_params)
    else
      return render status: :forbidden, text: 'Unable to add Billing Task because a Billing Task already exists for this paper. Note that you may not have permission to view the Billing Task card.'
    end

    respond_with(task, location: task_url(task))
  end

  def update
    requires_user_can :edit, task

    # if the task is completed the only thing that can be done to it is mark
    # it as uncompleted
    if task.completed?
      attrs = params.require(:task).permit(:completed)
      task.update!(completed: attrs[:completed]) if attrs.key?(:completed)
    else
      task.assign_attributes(task_params(task.class))
      task.save!
    end

    task.after_update
    Activity.task_updated! task, user: current_user

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
    # Exclude the root node
    content = task.card.try(:content_for_version_without_root, :latest) || []
    respond_with(
      content,
      each_serializer: CardContentAsNestedQuestionSerializer,
      root: "nested_questions"
    )
  end

  def nested_question_answers
    requires_user_can :view, task
    respond_with(
      task.answers,
      each_serializer: AnswerAsNestedQuestionAnswerSerializer,
      root: "nested_question_answers"
    )
  end

  private

  def paper
    paper_id = params[:paper_id] || params.dig(:task, :paper_id)
    unless paper_id
      task = Task.find(params[:id] || params[:task_id])
      paper_id = task.paper_id
    end
    @paper ||= Paper.find_by_id_or_short_doi(paper_id)
  end

  def does_not_violate_single_billing_task_condition?
    billing_type_string = 'PlosBilling::BillingTask'
    if task_type.to_s == billing_type_string
      paper.tasks.where(type: billing_type_string).count.zero?
    else
      true
    end
  end

  def task
    @task ||= begin
      if params[:id].present?
        Task.find(params[:id])
      elsif params[:task_id].present?
        Task.find(params[:task_id])
      end
    end
  end

  def task_type
    Task.safe_constantize(params[:task][:type])
  end

  def new_task_params
    task_params(task_type).dup.tap do |new_params|
      # for all new tasks, assign necessary paper attributes
      new_params[:paper] = paper
      new_params[:creator] = paper.creator

      # for custom cards, assign the latest card version
      if params[:task][:type] == 'CustomCardTask'
        new_params[:card_version] = card_version
      end
    end
  end

  def card_version
    @card_version ||= begin
      card = paper.journal.cards.find_by(id: params[:task][:card_id])
      card.latest_published_card_version
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
end
