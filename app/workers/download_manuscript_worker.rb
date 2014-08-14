class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(manuscript_id, url)
    manuscript = Manuscript.find(manuscript_id)
    manuscript.source.download!(url)
    manuscript.status = "done"
    manuscript.save

    epub = EpubConverter.new manuscript.paper, User.first, true

    response = Typhoeus.post(
      "http://localhost:3000/convert/docx",
      body: {
        epub: epub.epub_stream.string
      }
    )

    manuscript.paper.update JSON.parse(response.body).symbolize_keys!
  end
end
