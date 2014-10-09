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
    response_body = Faraday.get("#{ENV['IHAT_URL']}jobs/#{job_id}").body
    json = JSON.parse response_body, symbolize_names: true
    get_converted_epub = Faraday.get json[:jobs][:converted_epub_url]
    converted_epub_file = Tempfile.new ["converted_manuscript", ".epub"]
    converted_epub_file.binmode
    converted_epub_file.write get_converted_epub.body
    converted_epub_file.close

    json = nil
    Zip::File.open(converted_epub_file.path) do |file|
      file.each do |entry|
        json = entry.get_input_stream.read if entry.name == 'converted.json'
      end
    end

    JSON.parse json, symbolize_names: true
  end
end
