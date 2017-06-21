class RouterUploaderService
  include UrlBuilder
  class APIError < StandardError; end

  def initialize(file_io:, final_filename:, email_on_failure:, url:)
    @file_io = file_io,
    @final_filename = final_filename,
    @email_on_failure = email_on_failure,
    @url = 'http://aa-dev.plos.org'
  end

  def upload
    conn = Faraday.new(url: @url) do |faraday|
      faraday.response :json
      faraday.request :multipart
      faraday.request  :url_encoded
      faraday.use :gzip
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :net_http
    end

    tempfile = Tempfile.new('temp_package')
    tempfile.write(Zip::File.open(@file_io.first))

    params = {
      # client id and secret are Aperta's id and secret, NOT the end user's
      # 'client_id' => TahiEnv.orcid_key,
      # 'client_secret' => TahiEnv.orcid_secret,
      # 'grant_type' => 'authorization_code',
      # 'code' => code
    }
    binding.pry
    response = conn.post("/api/delivery", params) do |request|
      request.body = { archive_filename: @final_filename,
                       metadata_filename: 'metadata.json',
                       file: Faraday::UploadIO.new(tempfile.path, 'zip'),
                       files:'pbio.pdf',
                       aperta_id: 'some id',
                       destination: 'em',
                       journal_code: 'pcompbiol'
                     }
      request.headers['Accept'] = 'application/json'
      request.headers['Accept-Charset'] = "UTF-8"
    end
    tempfile.close
  end
end
