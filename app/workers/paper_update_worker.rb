class PaperUpdateWorker
  include Sidekiq::Worker

  attr_reader :paper, :epub_stream

  def perform(ihat_job_params)
    job_response = IhatJobResponse.new(ihat_job_params.with_indifferent_access)
    @paper = Paper.find(job_response.paper_id)
    if job_response.completed?
      @epub_stream = Faraday.get(job_response.epub_url).body
      sync!
      Notifier.notify(event: "paper:data_extracted", data: { record: paper })
    end
  end

  def sync!
    paper.transaction do
      PaperAttributesExtractor.new(epub_stream).sync!(paper)
      FiguresExtractor.new(epub_stream).sync!(paper)
    end
  end
end
