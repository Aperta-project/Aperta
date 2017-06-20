# External Correspondence Attachments
class CorrespondenceAttachmentsController < ApplicationController
  before_action :authenticate_user!, :ensure_correspondence

  respond_to :json

  def create
    @attachment = @correspondence.attachments.create
    DownloadAttachmentWorker.perform_async(
      @attachment.id,
      params[:url],
      current_user.id
    )
    render json: @attachment, status: :ok
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
