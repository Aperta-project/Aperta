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
    protocol, host, port = if ENV['IHAT_CALLBACK_URL']
            uri = URI.parse(ENV['IHAT_CALLBACK_URL'])
            [uri.scheme, uri.host, uri.port]
          else
            [rack_request.protocol, rack_request.host, rack_request.port]
          end

    UrlHelpers.ihat_jobs_url(protocol: protocol, host: host, port: port)
  end

  # +download_manuscript+ schedules a background job to download the paper's
  # manuscript at the provided url, on behalf of the given user.
  # ihat will post to the given callback url when the job is finished
  def self.download_manuscript(paper, url, user, callback_url)
    if url.present?
      perform_async(
        paper.id,
        url,
        callback_url,
        paper_id: paper.id,
        user_id: user.id
      )
      paper.update_attribute(:processing, true)
    end
  end

  # +perform+ should not be called directly, but by the background job
  # processor. Use the DownloadManuscriptWorker.download_manuscript
  # instead when calling from application code.
  def perform(paper_id, download_url, callback_url, metadata)
    paper = Paper.find(paper_id)
    download_manuscript(paper, download_url)
    epub_stream = get_epub(paper)

    TahiEpub::Tempfile.create epub_stream, delete: true do |file|
      request = IhatJobRequest.new(file: file,
                                   recipe_name: ihat_recipe_name(download_url),
                                   callback_url: callback_url,
                                   metadata: metadata)
      PaperConverter.post_ihat_job(request)
    end
  end

  private

  def download_manuscript(paper, url)
    attachment = paper.file || paper.create_file

    # download needs to ensure the attachment is saved first
    attachment.download!(url)

    # This will upload the content to the desired location in S3
    # latest_version.save!
  end

  def get_epub(paper)
    converter = EpubConverter.new(
      paper,
      paper.creator,
      include_source: true,
      include_cover_image: false)
    converter.epub_stream.string
  end

  def ihat_recipe_name(url)
    kind = Pathname.new(url).extname.delete(".")
    IhatJobRequest.recipe_name(from_format: kind, to_format: 'html')
  end
end
