class QuestionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :enforce_policy, except: [:create, :update]
  respond_to :json

  def create
    new_params = params.permit(
      question_attachment: [:nested_question_answer_id, :src, :filename, :title]
    )[:question_attachment]

    answer = NestedQuestionAnswer.where(
      id: new_params[:nested_question_answer_id]
    ).first!

    q3 = question_attachment = answer.attachments.create(
      title: new_params[:title]
    )

    DownloadQuestionAttachmentWorker.perform_async question_attachment.id, new_params[:src]

    render json: { "question-attachment": { id: question_attachment.id } }
  end

  def update
    new_params = params.permit(
      question_attachment: [:src, :filename, :title]
    )[:question_attachment]

    question_attachment = QuestionAttachment.find(params[:id])
    question_attachment.update title: new_params[:title]

    DownloadQuestionAttachmentWorker.perform_async question_attachment.id, new_params[:src]

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
end
