class DownloadAdhocTaskAttachmentWorker
  include Sidekiq::Worker

  def perform(task_id, url)
    task = Task.find task_id
    attachment = task.attachments.create
    attachment.file.download! url
    attachment.save
  end
end

