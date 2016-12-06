# The DownloadAttachmentWorker can be used to download and process
# any Attachment, e.g. AdhocAttachment, Figure, SupportingInformationFile, etc.
class DownloadAttachmentWorker
  include Sidekiq::Worker

  # Retries here could cause figures or supporting information to
  # revert to a broken file after the error had been fixed
  sidekiq_options retry: false

  def self.download_attachment(attachment, url, uploaded_by_user)
    attachment.update_attribute(:status, Attachment::STATUS_PROCESSING)
    perform_async(attachment.id, url, uploaded_by_user.id)
  end

  def perform(attachment_id, url, uploaded_by_user_id)
    Rails.logger.info "Downloading attachment #{attachment_id} from #{url} for user #{uploaded_by_user_id}"
    user = User.find(uploaded_by_user_id)
    attachment = Attachment.find(attachment_id)
    attachment.download!(url, uploaded_by: user)

  rescue ActiveRecord::RecordNotFound => ex
    Rails.logger.info "Caught Attachment cancel: #{ex.message}"
    # No-op. This is a user canceling a processing job

  rescue Exception => ex
    paper = attachment.paper
    tab_info = {
      attachment_temporary_url: url,
      paper_id: paper.id,
      paper_doi: paper.doi,
      attachment_owner_id: attachment.owner_id,
      attachment_owner_type: attachment.owner_type
    }
    Rails.logger.error "Attachment failed processing: #{ex.message}, info: #{tab_info}"
    Bugsnag.notify(ex) do |notification|
      notification.add_tab :attachment_info, tab_info
    end
  end
end
