# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# QuestionAttachmentsController is responsible for uploading files/attachments
# for nested question answers.
class QuestionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def create
    requires_user_can :edit, question_attachment.find_task
    question_attachment.update(caption: attachment_params[:caption])
    process_attachments(question_attachment, attachment_params[:src])
    render json: { 'question-attachment': { id: question_attachment.id } }
  end

  def update
    requires_user_can :edit, question_attachment.find_task
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
    requires_user_can_view(question_attachment)
    respond_with question_attachment
  end

  def destroy
    requires_user_can :edit, question_attachment.find_task
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
