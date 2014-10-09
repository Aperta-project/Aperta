class PaperUpdateWorker
  include Sidekiq::Worker

  attr_accessor :job_id

  def perform(job_id)
    @job_id = job_id
    job.paper.update! paper_attributes
  end

  def job
    IhatJob.find_by(job_id: job_id)
  end

  def paper_attributes
    json = Faraday.get("#{ENV['IHAT_URL']}jobs/#{job_id}/download")[:json]
    JSON.parse json, symbolize_names: true
  end
end
