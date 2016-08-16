# The InvitationAttachmentsController provides end-points for interacting with and
# retrieving an invitation's Attachment(s).
class InvitationAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    fail AuthorizationError unless invitation.can_be_viewed_by?(current_user)
    respond_with invitation.attachments, root: 'attachments'
  end

  def show
    fail AuthorizationError unless invitation.can_be_viewed_by?(current_user)
    respond_with attachment, root: 'attachment'
  end

  def create
    requires_user_can(:manage_invitations, invitation.task)
    attachment = invitation.attachments.create
    DownloadAttachmentWorker.perform_async(attachment.id, params[:url])
    render json: attachment, root: 'attachment'
  end

  def destroy
    requires_user_can(:manage_invitations, invitation.task)
    attachment.destroy
    head :no_content
  end

  def update
    requires_user_can(:manage_invitations, invitation.task)
    attachment.update_attributes attachment_params
    respond_with attachment, root: 'attachment'
  end

  # Actually updates the attached file
  def update_attachment
    requires_user_can(:manage_invitations, invitation.task)
    attachment.update_attribute(:status, 'processing')
    DownloadAttachmentWorker.perform_async(attachment.id, params[:url])
    render json: attachment, root: 'attachment'
  end

  private

  def invitation
    @invitation ||= Invitation.find(params[:invitation_id])
  end

  def attachment
    @attachment ||= Attachment.find(params[:id])
  end

  def attachment_params
    params.require(:invitation_attachment).permit(:title, :caption, :kind)
  end
end
