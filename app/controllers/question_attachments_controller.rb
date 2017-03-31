# QuestionAttachmentsController is responsible for uploading files/attachments
# for nested question answers.
class QuestionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can :edit, task_for(question_attachment)
    question_attachment.update(caption_html: attachment_params[:caption_html])
    process_attachments(question_attachment, attachment_params[:src])
    render json: { 'question-attachment': { id: question_attachment.id } }
  end

  def update
    requires_user_can :edit, task_for(question_attachment)
    question_attachment.update caption_html: attachment_params[:caption_html]
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
        answer = Answer.where(
          id: attachment_params[:nested_question_answer_id]
        ).first!
        answer.attachments.build
      end
    end
  end

  # rubocop:disable Style/CyclomaticComplexity,Style/PerceivedComplexity
  def task_for(question_attachment)
    @task ||= begin
      owner = question_attachment
      until owner.is_a? Task
        if owner.respond_to?(:owner) && !owner.owner.nil?
          owner = owner.owner
        elsif owner.respond_to?(:card_content) && !owner.card_content.nil?
          owner = owner.card_content
        elsif owner.respond_to? :answer
          owner = owner.answer
        else
          raise ArgumentError, "Cannot find task for question attachment"
        end
      end
    end
    owner
  end
  # rubocop:enable Style/CyclomaticComplexity,Style/PerceivedComplexity

  def process_attachments(question_attachment, url)
    DownloadAttachmentWorker.perform_async question_attachment.id, url, current_user.id
  end

  def attachment_params
    params.permit(
      question_attachment: [
        :nested_question_answer_id,
        :src, :filename,
        :title_html,
        :caption_html
      ]
    )[:question_attachment]
  end
end
