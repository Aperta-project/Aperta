class NestedQuestionAnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    answer = fetch_and_update_answer
    process_attachment(answer) if answer.save!
    render json: answer, serializer: NestedQuestionAnswerSerializer
  end

  def update
    answer = fetch_and_update_answer
    process_attachment(answer) if answer.save!
    render json: answer, serializer: NestedQuestionAnswerSerializer
  end

  def destroy
    answer = fetch_answer
    answer.destroy
    render json: answer, serializer: NestedQuestionAnswerSerializer
  end

  private

  def fetch_and_update_answer
    answer = fetch_answer
    answer.value = answer_params[:value]
    answer.additional_data = answer_params[:additional_data]
    answer
  end

  def fetch_answer
    @answer ||= begin
      answer = NestedQuestionAnswer.find(params[:id]) if params[:id]
      unless answer
        answer = owner.find_or_build_answer_for(nested_question: nested_question)
      end
      answer
    end
  end

  def owner
    @owner ||= owner_type.find(answer_params[:owner_id])
  end

  def owner_type
    NestedQuestion.lookup_owner_type(answer_params[:owner_type])
  end

  def nested_question
    @nested_question ||= begin
      nested_question_id = params.permit(:nested_question_id).fetch(:nested_question_id)
      NestedQuestion.find(nested_question_id)
    end
  end

  def answer_params
    @answer_params ||= params.require(:nested_question_answer).permit(:owner_id, :owner_type, :value, :decision_id).tap do |whitelisted|
      whitelisted[:additional_data] = params[:nested_question_answer][:additional_data]
    end
  end

  def enforce_policy
    authorize_action!(nested_question_answer: fetch_answer)
  end

  def has_attachment?
    nested_question.attachment? && answer_params[:value].present?
  end

  def process_attachment(answer)
    return unless has_attachment?

    attachment = answer.attachment || answer.build_attachment
    attachment.update_attribute :status, "processing"
    DownloadQuestionAttachmentWorker.perform_async attachment.id, answer_params[:value]
  end

end
