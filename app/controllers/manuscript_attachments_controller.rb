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
end
