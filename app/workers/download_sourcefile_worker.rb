# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'tahi_epub'

# Used to download the sourcefile from S3's pending directory and re-upload
# it to S3's upload directory
class DownloadSourcefileWorker
  include Sidekiq::Worker

  sidekiq_options :retry => false

  def self.download(paper, url, current_user)
    if url.blank?
      fail(ArgumentError, "Url must be provided (received a blank value)")
    end
    paper.update_attribute(:processing, true)
    perform_async(
      paper.id,
      url,
      current_user.id
    )
  end

  def perform(paper_id, download_url, current_user_id)
    paper = Paper.find(paper_id)
    uploaded_by = current_user_id.present? ? User.find(current_user_id) : nil
    paper.download_sourcefile!(download_url, uploaded_by: uploaded_by)
  end
end
