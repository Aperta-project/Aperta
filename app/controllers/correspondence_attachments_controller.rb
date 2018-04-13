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

# External Correspondence Attachments
class CorrespondenceAttachmentsController < ApplicationController
  before_action :authenticate_user!, :ensure_correspondence

  respond_to :json

  def create
    attachment = @correspondence.attachments.create
    DownloadAttachmentWorker.perform_async(
      attachment.id,
      correspondence_attachments_params[:src],
      current_user.id
    )
    render json: attachment, status: :ok
  end

  def update
    attachment = CorrespondenceAttachment.find(params[:id])
    attachment.update(status: 'processing')
    DownloadAttachmentWorker.perform_async(
      attachment.id,
      correspondence_attachments_params[:src],
      current_user.id
    )
    head :no_content
  end

  def destroy
    CorrespondenceAttachment.find(params[:id]).delete
    head :no_content
  end

  def show
    attachment = CorrespondenceAttachment.find(params[:id])
    render json: attachment, status: :ok
  end

  private

  def ensure_correspondence
    correspondence_id = params[:correspondence_id]
    if correspondence_id
      @correspondence = Correspondence.find params[:correspondence_id]
      requires_user_can :manage_workflow, @correspondence.paper
    else
      render :not_found
    end
  end

  def correspondence_attachments_params
    params.require(:correspondence_attachment).permit(:src, :filename)
  end
end
