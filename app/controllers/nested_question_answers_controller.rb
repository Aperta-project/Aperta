class NestedQuestionAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    create_or_update_answer
    head 204
  end

  def update
    create_or_update_answer
    head 204
  end

  private

  def create_or_update_answer
    answer.update_attributes!(value: answer_params[:value])
  end

  def answer
    @answer ||= NestedQuestionAnswer.where(
      owner: task,
      nested_question_id: answer_params[:nested_question_id],
      value_type: nested_question.value_type
    ).first_or_initialize
  end

  def nested_question
    @nested_question ||= NestedQuestion.find(answer_params[:nested_question_id])
  end

  def task
    @task ||= Task.find(answer_params[:task_id])
  end

  def answer_params
    params.require(:nested_question_answer).permit(:task_id, :nested_question_id, :value)
  end

  def enforce_policy
    authorize_action!(nested_question_answer: answer)
  end
end
