class DownloadAdhocTaskAttachmentWorker
  include Sidekiq::Worker

  def perform(attachment_id, url)
    attachment = Attachment.find(attachment_id)
    attachment.file.download! url
    attachment.title = attachment.file.filename
    if attachment.save
      attachment.update_column('status', 'done')
    end
  end
end

