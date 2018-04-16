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

# The AdhocAttachmentsController provides end-points for interacting with and
# retrieving a task's AdhocAttachment(s).
class AdhocAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can :view, task
    respond_with task.attachments, root: 'attachments'
  end

  def show
    attachment = Attachment.find(params[:id])
    requires_user_can :view, attachment.task
    respond_with attachment, root: 'attachment'
  end

  def create
    requires_user_can :edit, task
    attachment = task.attachments.create
    DownloadAttachmentWorker.perform_async(attachment.id, params[:url], current_user.id)
    render json: attachment, root: 'attachment'
  end

  def destroy
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.task
    attachment.destroy
    head :no_content
  end

  def update
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.task
    attachment.update_attributes attachment_params
    respond_with attachment, root: 'attachment'
  end

  def update_attachment
    attachment = task.attachments.find(params[:id])
    requires_user_can :edit, attachment.task
    attachment.update_attribute(:status, 'processing')
    DownloadAttachmentWorker.perform_async(attachment.id, params[:url], current_user.id)
    render json: attachment, root: 'attachment'
  end

  def cancel
    attachment = Attachment.find(params[:id])
    if attachment.invitation
      requires_user_can(:manage_invitations, attachment.invitation.task)
    else
      requires_user_can :edit, attachment.task
    end

    attachment.cancel_download

    head :no_content
  end

  private

  def task
    @task ||= Task.find(params[:task_id])
  end

  def attachment_params
    params.require(:attachment).permit(:title, :caption, :kind)
  end
end
