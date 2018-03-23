# The InvitationAttachmentsController provides end-points for interacting with
# and retrieving an invitation's Attachment(s).
class InvitationAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can_view(invitation)
    respond_with invitation.attachments, root: 'attachments'
  end

  def show
    requires_user_can_view(invitation)
    respond_with attachment, root: 'attachment'
  end

  def create
    requires_user_can(:manage_invitations, invitation.task)
    new_attachment = invitation.attachments.create
    DownloadAttachmentWorker.perform_async(new_attachment.id, params[:url], current_user.id)
    render json: new_attachment, root: 'attachment'
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
    DownloadAttachmentWorker.perform_async(attachment.id, params[:url], current_user.id)
    render json: attachment, root: 'attachment'
  end

  private

  def invitation
    @invitation ||= Invitation.find(params[:invitation_id])
  end

  def attachment
    @attachment ||= invitation.attachments.find(params[:id])
  end

  def attachment_params
    params.require(:invitation_attachment).permit(:title, :caption, :kind)
  end
end
