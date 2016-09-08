# The AdhocAttachmentsController provides end-points for interacting with and
# retrieving a task's AdhocAttachment(s).
class AdhocAttachmentsController < ApplicationController
  before_action :authenticate_user!
  respond_to :json

  def index
    requires_user_can :view, task
    respond_with task.attachments, root: 'attachments'
  end

  def show
    attachment = Attachment.find(params[:id])
    requires_user_can :view, attachment.task
    respond_with attachment, root: 'attachment'
  end

  def create
    requires_user_can :edit, task
    attachment = task.attachments.create
    DownloadAttachmentWorker.perform_async(attachment.id, params[:url], current_user.id)
    render json: attachment, root: 'attachment'
  end

  def destroy
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.task
    attachment.destroy
    head :no_content
  end

  def update
    attachment = Attachment.find(params[:id])
    requires_user_can :edit, attachment.task
    attachment.update_attributes attachment_params
    respond_with attachment, root: 'attachment'
  end

  def update_attachment
    attachment = task.attachments.find(params[:id])
    requires_user_can :edit, attachment.task
    attachment.update_attribute(:status, 'processing')
    DownloadAttachmentWorker.perform_async(attachment.id, params[:url], current_user.id)
    render json: attachment, root: 'attachment'
  end

  def cancel
    attachment = Attachment.find(params[:id])
    case attachment.status
    when Attachment::STATUS_PROCESSING
      # delete the figure and let sidekiq deal with it
      #
      # sidekiq still running
      attachment.destroy
    when Attachment::STATUS_ERROR
      # clean up from exception in sidekiq
      #
      # sidekiq not running due to exception
      attachment.destroy
    when Attachment::STATUS_DONE
      # sidekiq completely done, two ships passing in the night
      # no-op
    end
    head :no_content
  end

  private

  def task
    @task ||= Task.find(params[:task_id])
  end

  def attachment_params
    params.require(:attachment).permit(:title, :caption, :kind)
  end
end
