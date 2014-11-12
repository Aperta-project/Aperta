# TODO: Refactor this
class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(manuscript_id, url)
    @manuscript_id = manuscript_id
    @url = url

    download_manuscript_source && update_manuscript

    epub_stream = EpubConverter.new(manuscript.paper, User.first, true).epub_stream.string
    TahiEpub::Tempfile.create epub_stream, delete: true do |file|
      post_ihat_job(file)
    end
  end

  private

  def post_ihat_job(file)
    RestClient.post(
      "#{ENV['IHAT_URL']}/jobs",
      epub: file,
      multipart: true,
      callback_url: '/ihat_callback',
      state: { paper_id: manuscript.paper.id }
    )
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
