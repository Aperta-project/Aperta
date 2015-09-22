class NestedQuestionAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    answer = fetch_answer
    if answer.save!
      process_attachment(answer)
    end
    render json: answer, serializer: NestedQuestionAnswerSerializer
  end

  def update
    answer = fetch_answer
    updated_attrs = {
      value: answer_params[:value],
      additional_data: answer_params[:additional_data]
    }
    if answer.update_attributes!(updated_attrs)
      process_attachment(answer)
    end
    render json: answer, serializer: NestedQuestionAnswerSerializer
  end

  private

  def fetch_answer
    @fetch_answer ||= begin
      if params[:id]
        NestedQuestionAnswer.where(id: params[:id]).first!
      else
        NestedQuestionAnswer.new(
          nested_question_id: nested_question.id,
          value_type: nested_question.value_type,
          value: answer_params[:value],
          owner_id: answer_params[:owner_id],
          owner_type: lookup_owner_type(answer_params[:owner_type]),
          additional_data: answer_params[:additional_data]
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

  def answer_params
    @answer_params ||= params.require(:nested_question_answer).permit(:owner_id, :owner_type, :value).tap do |whitelisted|
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
      raise "Don't know how to assign to #{answer_params[:owner_type]}"
    end
  end

  def enforce_policy
    authorize_action!(nested_question_answer: fetch_answer)
  end

  def has_attachment?
    nested_question.value_type == "attachment" && answer_params[:value].present?
  end

  def process_attachment(answer)
    if has_attachment?
      attachment = answer.attachment || answer.build_attachment
      attachment.update_attribute :status, "processing"
      DownloadQuestionAttachmentWorker.perform_async attachment.id, answer_params[:value]
    end
  end

end
