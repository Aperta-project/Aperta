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
    Epub::JSONParser.parse(convert_json)
  end

  def convert_json
    epub_stream = get_converted_epub Epub::JSONParser.parse(response_body)

    Epub::Tempfile.create epub_stream do |file|
      extract_file_from_zip file: 'converted.json',
                            zipped_file_path: file.path
    end
  end

  def response_body
    Faraday.get("#{ENV['IHAT_URL']}jobs/#{job_id}").body
  end

  def get_converted_epub(job_response)
    Faraday.get(job_response[:jobs][:converted_epub_url]).body
  end

  def extract_file_from_zip(file:, zipped_file_path:)
    Zip::File.open(zipped_file_path) do |file|
      return file.glob("converted.json").first.get_input_stream.read
    end
  end
end
