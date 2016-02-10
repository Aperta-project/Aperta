# QuestionAttachmentsController is responsible for uploading files/attachments
# for nested question answers.
class QuestionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy
  respond_to :json

  def create
    question_attachment.update(caption: attachment_params[:caption])
    process_attachments(question_attachment, attachment_params[:src])
    render json: { 'question-attachment': { id: question_attachment.id } }
  end

  def update
    question_attachment.update caption: attachment_params[:caption]

    process_attachments(question_attachment, attachment_params[:src])
    render json: { 'question-attachment': { id: question_attachment.id } }
  end

  def show
    respond_with question_attachment
  end

  def destroy
    question_attachment.destroy
    respond_with question_attachment
  end

  private

  def question_attachment
    @question_attachment ||= begin
      if params[:id]
        QuestionAttachment.find_by(id: params[:id])
      elsif attachment_params[:nested_question_answer_id]
        answer = NestedQuestionAnswer.where(
          id: attachment_params[:nested_question_answer_id]
        ).first!
        answer.attachments.build
      end
    end
  end

  def enforce_policy
    authorize_action!(question_attachment: question_attachment)
  end

  def process_attachments(question_attachment, url)
    DownloadQuestionAttachmentWorker.perform_async question_attachment.id, url
  end

  def attachment_params
    params.permit(
      question_attachment: [
        :nested_question_answer_id,
        :src, :filename,
        :title,
        :caption
      ]
    )[:question_attachment]
  end
end
