# TODO: Refactor this
class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(manuscript_id, url, callback_url)
    @manuscript_id = manuscript_id
    @url = url
    @callback_url = callback_url

    download_manuscript_source && update_manuscript

    epub_stream = EpubConverter.new(manuscript.paper, User.first, true).epub_stream.string
    TahiEpub::Tempfile.create epub_stream, delete: true do |file|
      response_attributes = post_ihat_job(file)
      IhatJob.create! paper: manuscript.paper, job_id: response_attributes[:jobs][:id]
    end
  end

  private

  def post_ihat_job(file)
    response = RestClient.post(
      "#{ENV['IHAT_URL']}/jobs",
      epub: file,
      multipart: true,
      callback_url: @callback_url
    )

    TahiEpub::JSONParser.parse response.body
  end

  def manuscript
    @manuscript ||= Manuscript.find(@manuscript_id)
  end

  def download_manuscript_source
    manuscript.source.download!(@url)
  end

  def update_manuscript
    manuscript.update! status: "done"
  end
end
