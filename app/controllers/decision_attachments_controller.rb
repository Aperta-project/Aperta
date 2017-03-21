# The DecisionAttachmentsController provides end-points for interacting with and
# retrieving a decision's attachments. DecisionAttachments are author responses
# to Decisions, so permissions here look peculiar on first blush. For example,
# to create a DecisionAttachment, the user must be able to edit the decision's
# paper's ReviseTask, but to show the attachment, the user must only be able to
# view the Decision the attachment is associated with.
class DecisionAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can :view, decision
    respond_with decision.attachments, root: 'attachments'
  end

  def show
    attachment = Attachment.find(params[:id])
    requires_user_can :view, attachment.owner
    respond_with attachment, root: 'attachment'
  end

  def create
    requires_user_can :edit, task
    attachment = decision.attachments.create
    DownloadAttachmentWorker.perform_async(
      attachment.id,
      params[:url],
      current_user.id
    )
    render json: attachment, root: 'attachment'
  end

  def destroy
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.revise_task
    attachment.destroy
    head :no_content
  end

  def update
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.revise_task
    attachment.update_attributes attachment_params
    respond_with attachment, root: 'attachment'
  end

  def update_attachment
    attachment = task.attachments.find(params[:id])
    requires_user_can :edit, attachment.revise_task
    attachment.update_attribute(:status, 'processing')
    DownloadAttachmentWorker.perform_async(
      attachment.id,
      params[:url],
      current_user.id
    )
    render json: attachment, root: 'attachment'
  end

  def cancel
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.revise_task

    attachment.cancel_download

    head :no_content
  end

  private

  def decision
    @decision ||= Decision.find(params[:decision_id])
  end

  def task
    @task ||= decision.paper.revise_task
  end

  def attachment_params
    params.require(:attachment).permit(:title, :caption, :kind)
  end
end
