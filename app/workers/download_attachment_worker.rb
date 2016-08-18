# The DownloadAttachmentWorker can be used to download and process
# any Attachment, e.g. AdhocAttachment, Figure, SupportingInformationFile, etc.
class DownloadAttachmentWorker
  include Sidekiq::Worker

  def perform attachment_id, url
    Attachment.transaction do
      Attachment.find(attachment_id).download!(url)
    end
  end
end
