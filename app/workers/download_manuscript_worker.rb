# Used to download the docx from S3 and send it to ihat for
# transformation into HTML.
class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(paper_id, download_url, callback_url, metadata)
    paper = Paper.find(paper_id)
    download_manuscript(paper, download_url)
    epub_stream = get_epub(paper)

    TahiEpub::Tempfile.create epub_stream, delete: true do |file|
      request = IhatJobRequest.new(file: file,
                                   recipe_name: 'docx_to_html',
                                   callback_url: callback_url,
                                   metadata: metadata)
      PaperConverter.post_ihat_job(request)
    end
  end

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
end
