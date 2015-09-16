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
      owner: owner,
      nested_question_id: nested_question.id,
      value_type: nested_question.value_type
    ).first_or_initialize
  end

  def nested_question
    @nested_question ||= begin
      nested_question_id = params.permit(:nested_question_id).fetch(:nested_question_id)
      NestedQuestion.find(nested_question_id)
    end
  end

  def owner
    @owner ||= begin
      case answer_params[:owner_type]
      when /Task$/
        Task.find(answer_params[:owner_id])
      when "Funder"
        TahiStandardTasks::Funder.find(answer_params[:owner_id])
      else
        raise "Don't know how to assign to #{answer_params[:owner_type]}"
      end
    end
  end

  def answer_params
    params.require(:nested_question_answer).permit(:owner_id, :owner_type, :value)
  end

  def enforce_policy
    authorize_action!(nested_question_answer: answer)
  end
end
