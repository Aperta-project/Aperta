# Used to download the docx from S3 and send it to ihat for
# transformation into HTML.
class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(manuscript_id, download_url, callback_url, metadata)
    manuscript = Manuscript.find(manuscript_id)
    manuscript.source.download!(download_url)
    request = IhatJobRequest.new(metadata)

    manuscript.save!
    epub_stream = EpubConverter.new(manuscript.paper, User.first, true).epub_stream.string
    TahiEpub::Tempfile.create epub_stream, delete: true do |file|
      PaperConverter.post_ihat_job(
        payload: Faraday::UploadIO.new(file, 'application/epub+zip'),
        options: {
          recipe_name: 'docx_to_html',
          callback_url: callback_url,
          metadata: request.encrypted_payload
        })
    end
  end
end
