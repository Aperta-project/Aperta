class DownloadAdhocTaskAttachmentWorker
  include Sidekiq::Worker

  def perform(attachment_id, url)
    Attachment.find(attachment_id).tap do |a|
      a.file.download! url
      a.title = a.file.filename
      a.status = "done"
      a.save
    end
  end
end

