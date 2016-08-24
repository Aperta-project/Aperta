# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'tahi_epub'

# Used to download the docx from S3 and send it to ihat for
# transformation into HTML.
class DownloadManuscriptWorker
  include Sidekiq::Worker


  UrlHelpers = Rails.application.routes.url_helpers

  # +build_ihat_callback_url+ is a utility method for use in a controller
  # context.  By default it builds the url using the request object's host and port,
  # but it can be overriden by the `IHAT_CALLBACK_URL` environment variable
  def self.build_ihat_callback_url(rack_request)
    url = ENV.fetch('IHAT_CALLBACK_URL', UrlHelpers.root_url)
    uri = URI.parse(url)

    UrlHelpers.ihat_jobs_url(
      protocol: uri.scheme,
      host: uri.host,
      port: uri.port)
  end

  # +download_manuscript+ schedules a background job to download the paper's
  # manuscript at the provided url, on behalf of the given user.
  # ihat will post to the given callback url when the job is finished
  def self.download_manuscript(paper, url, current_user)
    if url.present?
      perform_async(
        paper.id,
        url,
        current_user.id
      )
      paper.update_attribute(:processing, true)
    end
  end

  # +perform+ should not be called directly, but by the background job
  # processor. Use the DownloadManuscriptWorker.download_manuscript
  # instead when calling from application code.
  def perform(paper_id, download_url, current_user_id)
    paper = Paper.find(paper_id)
    uploaded_by = current_user_id.present? ? User.find(current_user_id) : nil
    paper.download_manuscript!(download_url, uploaded_by: uploaded_by)
  end
end
