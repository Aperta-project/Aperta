# QuestionAttachmentsController is responsible for uploading files/attachments
# for nested question answers.
class QuestionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can :edit, task_for(question_attachment)
    question_attachment.update(caption: attachment_params[:caption])
    process_attachments(question_attachment, attachment_params[:src])
    render json: { 'question-attachment': { id: question_attachment.id } }
  end

  def update
    requires_user_can :edit, task_for(question_attachment)
    question_attachment.update caption: attachment_params[:caption]
    process_attachments(question_attachment, attachment_params[:src])
    render json: { 'question-attachment': { id: question_attachment.id } }
  end

  def show
    requires_user_can :view, task_for(question_attachment)
    respond_with question_attachment
  end

  def destroy
    requires_user_can :edit, task_for(question_attachment)
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

  def task_for(question_attachment)
    @task ||= begin
      owner = question_attachment.nested_question_answer.owner
      owner = owner.owner until owner.class < Task
    end
    owner
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
