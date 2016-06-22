class DownloadAdhocTaskAttachmentWorker
  include Sidekiq::Worker

  def perform(attachment_id, url)
    attachment = AdhocAttachment.find(attachment_id)
    attachment.download! url
  end
end
