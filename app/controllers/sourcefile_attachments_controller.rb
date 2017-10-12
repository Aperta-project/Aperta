# SourcefileAttachmentsController contains the end-points responsible for
# interacting with SourcefileAttachment records over HTTP. Currently, the only
# publicly accessible action is #show.
class SourcefileAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    requires_user_can :view, attachment.paper
    respond_with attachment,
      root: 'attachment',
      serializer: AttachmentSerializer
  end

  def cancel
    requires_user_can :edit, attachment.paper.tasks.where(type: 'TahiStandardTasks::UploadManuscriptTask').first
    attachment.cancel_download

    head :no_content
  end

  def attachment
    SourcefileAttachment.find(params[:id])
  end
end
