# The DownloadAttachmentWorker can be used to download and process
# any Attachment, e.g. AdhocAttachment, Figure, SupportingInformationFile, etc.
class DownloadAttachmentWorker
  include Sidekiq::Worker

  def perform(attachment_id, url, uploaded_by_user_id)
    user = User.find(uploaded_by_user_id)
    Attachment.find(attachment_id).download!(url, uploaded_by: user)

  rescue ActiveRecord::RecordNotFound => ex
    Rails.logger.info "Caught Attachment cancel: #{ex.message}"
    # No-op. This is a user canceling a processing job
  end
end
