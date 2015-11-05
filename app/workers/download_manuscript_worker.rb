# TODO: Refactor this
class DownloadManuscriptWorker
  include Sidekiq::Worker

  attr_reader :download_url, :callback_url, :metadata, :manuscript

  def perform(manuscript_id, download_url, callback_url, metadata)
    @download_url = download_url
    @callback_url = callback_url
    @metadata = metadata
    @manuscript = Manuscript.find(manuscript_id)

    download_manuscript_source && update_manuscript

    epub_stream = EpubConverter.new(manuscript.paper, User.first, true).epub_stream.string
    TahiEpub::Tempfile.create epub_stream, delete: true do |file|
      PaperConverter.post_ihat_job(
        payload: Faraday::UploadIO.new(file, 'application/epub+zip'),
        options: {
          recipe_name: 'docx_to_html',
          callback_url: callback_url,
          metadata: metadata
        })
    end
  end

  private

  def download_manuscript_source
    manuscript.source.download!(download_url)
  end

  def update_manuscript
    manuscript.update! status: 'done'
  end
end
