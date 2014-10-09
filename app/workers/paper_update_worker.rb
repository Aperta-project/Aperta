require 'epub/tempfile'
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
    JSON.parse convert_json, symbolize_names: true
  end

  def convert_json
    Epub::Tempfile.create(parse_json(response_body)) { |file|
      binding.pry
      extract_file_from_zip file: 'converted.json',
                            zipped_file_path: file.path
    }
  end

  def response_body
    Faraday.get("#{ENV['IHAT_URL']}jobs/#{job_id}").body
  end

  def parse_json(json)
    JSON.parse json, symbolize_names: true
  end

  def get_converted_epub(job_response)
    Faraday.get job_response[:jobs][:converted_epub_url]
  end

  def create_tempfile(job_response)
    converted_epub_file = Tempfile.new ["converted_manuscript", ".epub"]
    converted_epub_file.binmode
    converted_epub_file.write get_converted_epub(job_response).body
    converted_epub_file.close
    converted_epub_file
  end

  def extract_file_from_zip(file:, zipped_file_path:)
    Zip::File.open(zipped_file_path) do |file|
      return file.glob("converted.json").first.get_input_stream.read
    end
  end
end
