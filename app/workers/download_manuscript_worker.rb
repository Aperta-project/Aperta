class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(manuscript_id, url)
    manuscript = Manuscript.find(manuscript_id)
    manuscript.source.download!(url)
    manuscript.status = "done"
    manuscript.save

    epub = EpubConverter.new manuscript.paper, User.first, true

    tempfile = Tempfile.new 'epub'
    tempfile.binmode
    tempfile.write epub.epub_stream.string
    tempfile.rewind

    response = RestClient.post(
      "http://localhost:3000/jobs", #ihat
      epub: tempfile,
      multipart: true,
      callback_url: "http://localhost:3001/ihat_jobs/:id" #tahi
    )
    response_attributes = JSON.parse(response.body).symbolize_keys!
    IhatJob.create! paper: manuscript.paper, job_id: response_attributes[:jobs]["id"]

  ensure
    tempfile.unlink
  end
end
