class AttachmentsController < ApplicationController
  def create
    DownloadAdhocTaskAttachmentWorker.perform_async(task.id, params[:url])
    render json: task
  end

  def remove_attachment

  end

  private

  def task
    @task ||= Task.find(params[:task_id])
  end
end
