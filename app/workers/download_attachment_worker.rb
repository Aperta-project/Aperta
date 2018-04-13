# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# The DownloadAttachmentWorker can be used to download and process
# any Attachment, e.g. AdhocAttachment, Figure, SupportingInformationFile, etc.
class DownloadAttachmentWorker
  include Sidekiq::Worker

  # Retries here could cause figures or supporting information to
  # revert to a broken file after the error had been fixed
  sidekiq_options retry: false

  def self.reprocess(attachment, uploaded_by)
    return if attachment.pending_url.nil?
    download_attachment(attachment, attachment.pending_url, uploaded_by)
  end

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
    attachment.update_attribute :status, Attachment::STATUS_ERROR
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
