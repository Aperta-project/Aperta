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

    payload = {
      metadata_filename: 'metadata.json',
      aperta_id: 'some id',
      files: 'something.pdf, something.png',
      destination: 'em',
      journal_code: 'pcompbiol',
      # The archive_filename is not a string but the file itself.
      archive_filename: Faraday::UploadIO.new(@file_io.first, '')
    }
    response = conn.post("/api/delivery") do |request|
      request.body = payload
    end
  end
end
