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
    # This check is the result of a timeboxed fix for a bug that manifests
    # itself when a user tries to update the caption for a question attachment
    # (see the PublishingRelatedQuestions card for an example). All of the other
    # controllers that deal with attachments split updating the attachment's url
    # into a separate 'update_attachment' action that gets hit when the user
    # hits the 'replace' button on the frontend. For some reason when both
    # happen at once the attachment fails processing with "Attachment failed
    # processing: trying to download a file which is not served over HTTP". The
    # logs in the attachment worker show the following: "Downloading attachment
    # 38 from /resource_proxy/WcFE8ca5raEopUYUSFHNU8oA for user 2". That log
    # should look more like: "Downloading attachment 39 from
    # http://aperta-tahi-review.s3-us-west-1.amazonaws.com/pending/2/ad-hoca5346047c90635d72b23/my-awesome-file.csv
    # for user 2"
    unless attachment_params[:src] == question_attachment.src
      process_attachments(question_attachment, attachment_params[:src])
    end
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
      else
        answer_id =
          attachment_params[:answer_id] ||
          attachment_params[:nested_question_answer_id]

        answer = Answer.where(
          id: answer_id
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
    DownloadAttachmentWorker.perform_async(question_attachment.id,
                                           url,
                                           current_user.id)
  end

  def attachment_params
    params.permit(
      question_attachment: [
        :answer_id,
        :nested_question_answer_id,
        :src, :filename,
        :title,
        :caption
      ]
    )[:question_attachment]
  end
end
