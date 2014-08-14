class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(manuscript_id, url)
    manuscript = Manuscript.find(manuscript_id)
    manuscript.source.download!(url)
    manuscript.status = "done"
    manuscript.save

    epub = EpubConverter.new manuscript.paper, User.first, true

    response = RestClient.post(
      "http://ihat-staging.herokuapp.com/convert/docx",
      epub: epub.epub_stream.string, multipart: true
    )

    manuscript.paper.update JSON.parse(response.body).symbolize_keys!
  end
end
