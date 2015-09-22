class NestedQuestionAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    answer = fetch_answer
    answer.save!
    render json: answer, serializer: NestedQuestionAnswerSerializer
  end

  def update
    answer = fetch_answer
    answer.update_attributes!(
      value: existing_answer_params[:nested_question_answer][:value],
      additional_data: existing_answer_params[:additional_data]
    )
    render json: answer, serializer: NestedQuestionAnswerSerializer
  end

  private

  def fetch_answer
    @fetch_answer ||= begin
      if params[:id]
        NestedQuestionAnswer.where(id: existing_answer_params[:id]).first!
      else
        NestedQuestionAnswer.new(
          nested_question_id: nested_question.id,
          value_type: nested_question.value_type,
          value: new_answer_params[:value],
          owner_id: new_answer_params[:owner_id],
          owner_type: lookup_owner_type(new_answer_params[:owner_type]),
          additional_data: new_answer_params[:additional_data]
        )
      end
    end
  end

  def nested_question
    @nested_question ||= begin
      nested_question_id = params.permit(:nested_question_id).fetch(:nested_question_id)
      NestedQuestion.find(nested_question_id)
    end
  end

  def new_answer_params
    @new_answer_params ||= params.require(:nested_question_answer).permit(:owner_id, :owner_type, :value).tap do |whitelisted|
      whitelisted[:additional_data] = params[:nested_question_answer][:additional_data]
    end
  end

  def existing_answer_params
    @existing_answer_params ||= params.permit(:id, nested_question_answer: [:value]).tap do |whitelisted|
      whitelisted[:additional_data] = params[:nested_question_answer][:additional_data]
    end
  end

  def lookup_owner_type(owner_type)
    case owner_type
    when /Task$/
      "Task"
    when "Funder"
      TahiStandardTasks::Funder.name
    when "ReviewerRecommendation"
      TahiStandardTasks::ReviewerRecommendation.ReviewerRecommendation.name
    else
      raise "Don't know how to assign to #{new_answer_params[:owner_type]}"
    end
  end

  def enforce_policy
    authorize_action!(nested_question_answer: fetch_answer)
  end
end
