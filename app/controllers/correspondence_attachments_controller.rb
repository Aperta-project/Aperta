# External Correspondence Attachments
class CorrespondenceAttachmentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @attachment = @correspondence.attachments.create
    DownloadAttachmentWorker.perform_async(
      @attachment.id,
      params[:url],
      current_user.id
    )
    respond_with attachment, root: 'correspondence-attachment'
  end
end
