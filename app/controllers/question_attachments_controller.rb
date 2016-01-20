class QuestionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:create, :update]
  respond_to :json

  def create
    answer = NestedQuestionAnswer.where(
      id: attachment_params[:nested_question_answer_id]
    ).first!

    question_attachment = answer.attachments.create(
      title: attachment_params[:title]
    )

    process_attachments(question_attachment, attachment_params[:src])
    render json: { "question-attachment": { id: question_attachment.id } }
  end

  def update
    question_attachment = QuestionAttachment.find(params[:id])
    question_attachment.update title: attachment_params[:title]

    process_attachments(question_attachment, attachment_params[:src])
    render json: { "question-attachment": { id: question_attachment.id } }
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
    @question_attachment ||= QuestionAttachment.find(params[:id])
  end

  def enforce_policy
    authorize_action!(question_attachment: question_attachment)
  end

  def process_attachments(question_attachment, url)
    DownloadQuestionAttachmentWorker.perform_async question_attachment.id, url
  end

  def attachment_params
    params.permit(
      question_attachment: [:nested_question_answer_id, :src, :filename, :title]
    )[:question_attachment]
  end
end
