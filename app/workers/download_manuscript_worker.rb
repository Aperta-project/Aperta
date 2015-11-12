# Used to download the docx from S3 and send it to ihat for
# transformation into HTML.
class DownloadManuscriptWorker
  include Sidekiq::Worker

  def perform(paper_id, download_url, callback_url, metadata)
    paper = Paper.find(paper_id)
    paper.latest_version.source.download!(download_url)
    # This will upload the content to the desired location in S3
    paper.latest_version.save!
    epub_stream = EpubConverter.new(paper, nil, true).epub_stream.string
    TahiEpub::Tempfile.create epub_stream, delete: true do |file|
      request = IhatJobRequest.new(file: file,
                                   recipe_name: 'docx_to_html',
                                   callback_url: callback_url,
                                   metadata: metadata)
      PaperConverter.post_ihat_job(request)
    end
  end
end
