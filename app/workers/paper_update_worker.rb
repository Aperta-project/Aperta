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
    TahiEpub::JSONParser.parse(convert_json)
  end

  def convert_json
    epub_stream = get_converted_epub TahiEpub::JSONParser.parse(response_body)
    TahiEpub::Zip.extract(stream: epub_stream, filename: 'converted.json')
  end

  def response_body
    Faraday.get("#{ENV['IHAT_URL']}/jobs/#{job_id}").body
  end

  def get_converted_epub(job_response)
    Faraday.get(job_response[:jobs][:url]).body
  end
end
