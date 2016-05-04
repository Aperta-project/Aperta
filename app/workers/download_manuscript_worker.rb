# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'tahi_epub'

# Used to download the docx from S3 and send it to ihat for
# transformation into HTML.
class DownloadManuscriptWorker
  include Sidekiq::Worker

  UrlHelpers = Rails.application.routes.url_helpers
  def self.download_manuscript(paper, s3_url, user)
    if s3_url.present?
      url_opts = { host: ENV['IHAT_CALLBACK_HOST'],
                   port: ENV['IHAT_CALLBACK_PORT'] }
                 .reject { |_, v| v.nil? }

      perform_async(
        paper.id,
        s3_url,
        UrlHelpers.ihat_jobs_url(url_opts),
        paper_id: paper.id,
        user_id: user.id
      )
      paper.update!(processing: true)
    end
  end

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
    latest_version = paper.latest_version
    latest_version.source.download!(url)
    # This will upload the content to the desired location in S3
    latest_version.save!
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
