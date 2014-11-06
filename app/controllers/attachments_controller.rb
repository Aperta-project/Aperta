class AttachmentsController < ApplicationController
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

  private

  def task
    @task ||= Task.find(params[:task_id])
  end
end
