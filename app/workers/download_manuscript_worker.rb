# TODO: Refactor this
class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(manuscript_id, url, callback_url)
    tempfile = Tempfile.new 'epub'

    manuscript = Manuscript.find(manuscript_id)
    manuscript.source.download!(url)
    manuscript.status = "done"
    manuscript.save

    epub = EpubConverter.new manuscript.paper, User.first, true

    tempfile.binmode
    tempfile.write epub.epub_stream.string
    tempfile.rewind

    response = RestClient.post(
      "#{ENV['IHAT_URL']}/jobs", #ihat
      epub: tempfile,
      multipart: true,
      callback_url: callback_url
    )
    response_attributes = TahiEpub::JSONParser.parse response.body
    IhatJob.create! paper: manuscript.paper, job_id: response_attributes[:jobs][:id]
  ensure
    tempfile.unlink
  end
end
