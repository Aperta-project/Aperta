class PaperUpdateWorker
  include Sidekiq::Worker

  attr_accessor :job_id

  def perform(paper_id, job_id)
    @job_results = JSON.parse(RestClient.get("#{ENV['IHAT_URL']}/jobs/#{job_id}"))
    paper = Paper.find(paper_id)
    paper.update! paper_attributes
  end

  def paper_attributes
    TahiEpub::JSONParser.parse(convert_json)
  end

  def convert_json
    TahiEpub::Zip.extract(stream: epub_stream, filename: 'converted.json')
  end

  def epub_stream
    Faraday.get(@job_results[:url]).body
  end
end
