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

# The DecisionAttachmentsController provides end-points for interacting with and
# retrieving a decision's attachments. DecisionAttachments are author responses
# to Decisions, so permissions here look peculiar on first blush. For example,
# to create a DecisionAttachment, the user must be able to edit the decision's
# paper's ReviseTask, but to show the attachment, the user must only be able to
# view the Decision the attachment is associated with.
class DecisionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can :view, decision
    respond_with decision.attachments, root: 'attachments'
  end

  def show
    attachment = Attachment.find(params[:id])
    revise_task = attachment.revise_task
    if revise_task.completed?
      requires_user_can :view, attachment.owner
    else
      requires_user_can :view, revise_task
    end
    respond_with attachment, root: 'decision-attachment'
  end

  def create
    requires_user_can :edit, task
    attachment = decision.attachments.create
    DownloadAttachmentWorker.perform_async(
      attachment.id,
      params[:url],
      current_user.id
    )
    render json: attachment, root: 'decision-attachment'
  end

  def destroy
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.revise_task
    attachment.destroy
    head :no_content
  end

  def update
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.revise_task
    attachment.update_attributes attachment_params
    respond_with attachment, root: 'attachment'
  end

  def update_attachment
    attachment = task.attachments.find_by_id(params[:id])
    attachment ||= decision.attachments.find(params[:id])
    requires_user_can :edit, attachment.revise_task
    attachment.update_attribute(:status, 'processing')
    DownloadAttachmentWorker.perform_async(
      attachment.id,
      params[:url],
      current_user.id
    )
    render json: attachment, root: 'attachment'
  end

  def cancel
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.revise_task

    attachment.cancel_download

    head :no_content
  end

  private

  def decision
    @decision ||= Decision.find(params[:decision_id])
  end

  def task
    @task ||= decision.paper.revise_task
  end

  def attachment_params
    params.require(:attachment).permit(:title, :caption, :kind)
  end
end
