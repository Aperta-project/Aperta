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

# ManuscriptAttachmentsController contains the end-points responsible for
# interacting with ManuscriptAttachment records over HTTP. Currently, the only
# publicly accessible action is #show.
class ManuscriptAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    attachment = ManuscriptAttachment.find(params[:id])
    requires_user_can :view, attachment.paper
    respond_with attachment, root: 'attachment', serializer: AttachmentSerializer
  end

  def cancel
    requires_user_can :edit, attachment.paper.tasks.where(type: 'TahiStandardTasks::UploadManuscriptTask').first
    attachment.cancel_download

    head :no_content
  end

  def attachment
    ManuscriptAttachment.find(params[:id])
  end
end
