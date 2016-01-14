class AttachmentsController < ApplicationController
  respond_to :json

  def index
    respond_with task.attachments
  end

  def show
    respond_with Attachment.find(params[:id])
  end

  def create
    attachment = task.attachments.create
    DownloadAdhocTaskAttachmentWorker.perform_async(attachment.id, params[:url])
    render json: attachment
  end

  def destroy
    attachment = Attachment.find(params[:id])
    attachment.destroy
    head :no_content
  end

  def update
    attachment = Attachment.find(params[:id])
    attachment.update_attributes attachment_params
    respond_with attachment
  end

  def update_attachment
    attachment = task.attachments.find(params[:id])
    attachment.update_attribute(:status, 'processing')
    DownloadAdhocTaskAttachmentWorker.perform_async(attachment.id, params[:url])
    render json: attachment
  end

  private

  def task
    @task ||= Task.find(params[:task_id])
  end

  def attachment_params
    params.require(:attachment).permit(:title, :caption, :kind)
  end
end
