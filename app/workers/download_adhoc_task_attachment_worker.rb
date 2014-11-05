class DownloadAdhocTaskAttachmentWorker
  include Sidekiq::Worker

  def perform(task_id, url)
    task = Task.find task_id
    attachment = task.attachments.create
    attachment.file.download! url
    attachment.title = attachment.file.filename
    attachment.save
  end
end

