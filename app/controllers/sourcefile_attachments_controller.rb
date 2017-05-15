# SourcefileAttachmentsController contains the end-points responsible for
# interacting with SourcefileAttachment records over HTTP. Currently, the only
# publicly accessible action is #show.
class SourcefileAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def show
    attachment = SourcefileAttachment.find(params[:id])
    requires_user_can :view, attachment.paper
    respond_with attachment,
      root: 'attachment',
      serializer: AttachmentSerializer
  end
end
