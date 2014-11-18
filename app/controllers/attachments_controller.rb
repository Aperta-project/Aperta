class AttachmentsController < ApplicationController
  respond_to :json

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
    attachment.update(attachment_params)
    respond_with attachment
  end

  private

  def task
    @task ||= Task.find(params[:task_id])
  end

  def attachment_params
    params.require(:attachment).permit(:title, :caption)
  end
end
