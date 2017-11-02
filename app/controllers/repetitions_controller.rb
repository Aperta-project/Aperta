class RepetitionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:view, task)
    respond_with task.repetitions
  end

  def create
    requires_user_can(:edit, task)
    repetition = Repetition.create(repetition_params)
    render json: repetition_positions(first: repetition)
  end

  def update
    repetition = Repetition.find(params[:id])
    requires_user_can(:edit, repetition.task)
    repetition.update(repetition_params)
    render json: repetition_positions(first: repetition)
  end

  def destroy
    repetition = Repetition.find(params[:id])
    requires_user_can(:edit, repetition.task)
    repetition.destroy
    render json: repetition_positions(first: repetition)
  end

  private

  def task
    @task ||= Task.find(params[:task_id] || repetition_params[:task_id])
  end

  def card_content
    @card_content ||= CardContent.find(repetition_params[:card_content_id])
  end

  def repetition_params
    params.require(:repetition).permit(
      :card_content_id,
      :task_id,
      :parent_id,
      :position
    )
  end

  # Return an array of sibling repetitions so that positions can be returned to
  # the client.  Ember expects that when returning an array for a single object
  # action (create / update / destroy), the first object must be the one that
  # was modified.
  def repetition_positions(first:)
    [first] + first.siblings
  end
end
