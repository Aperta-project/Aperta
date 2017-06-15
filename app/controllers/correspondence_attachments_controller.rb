# External Correspondence Attachments
class CorrespondenceAttachmentsController < ApplicationController
  before_action :authenticate_user!, :ensure_correspondence

  def create
    @attachment = @correspondence.attachments.create
    DownloadAttachmentWorker.perform_async(
      @attachment.id,
      params[:url],
      current_user.id
    )
    respond_with attachment, root: 'correspondence-attachment'
  end

  private

  def ensure_correspondence
    correspondence_id = params[:correspondence_id]
    if correspondence_id
      @correspondence = Correspondence.find params[:correspondence_id]
    else
      render :not_found
    end
  end
end
