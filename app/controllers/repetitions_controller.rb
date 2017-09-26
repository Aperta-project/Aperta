class RepetitionsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can(:view, task)
    respond_with task.repetitions
  end

  def create
    requires_user_can(:edit, task)
    # TODO: should this also create answers?
    respond_with Repetition.create(repetition_params)
  end

  def update
    repetition = Repetition.find(params[:id])
    requires_user_can(:edit, repetition.task)
    repetition.update(repetition_params)
    respond_with repetition
  end

  def destroy
    repetition = Repetition.find(params[:id])
    requires_user_can(:edit, repetition.task)
    respond_with repetition.destroy
  end

  private

  def task
    @task ||= Task.find(repetition_params[:task_id])
  end

  def card_content
    @card_content ||= CardContent.find(repetition_params[:card_content_id])
  end

  def repetition_params
    params.require(:repetition).permit(
      :card_content_id,
      :task_id,
      :parent_id
    )
  end
end
