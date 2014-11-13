class DownloadAdhocTaskAttachmentWorker
  include Sidekiq::Worker

  def perform(attachment_id, url)
    attachment = Attachment.find(attachment_id)
    attachment.file.download! url
    attachment.title = attachment.file.filename
    attachment.status = "done"
    attachment.save
  end
end

