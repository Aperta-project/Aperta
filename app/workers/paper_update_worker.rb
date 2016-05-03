# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'notifier'

class PaperUpdateWorker
  include Sidekiq::Worker

  attr_reader :paper, :epub_stream

  def perform(ihat_job_params)
    job_response = IhatJobResponse.new(ihat_job_params.with_indifferent_access)
    @paper = Paper.find(job_response.paper_id)
    if job_response.completed?
      @epub_stream = Faraday.get(job_response.format_url(:epub)).body
      sync!
    end
    Notifier.notify(event: "paper:data_extracted", data: { record: job_response })
  end

  def sync!
    # use transaction to wait until all work is done before firing commit events
    paper.transaction do
      PaperAttributesExtractor.new(epub_stream).sync!(paper)
      paper.update!(processing: false)
    end
  end
end
