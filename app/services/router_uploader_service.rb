class RouterUploaderService
  include UrlBuilder
  class APIError < StandardError; end

  def initialize(destination:, email_on_failure:, file_io:, filenames:, final_filename:, paper:, url:)
    @destination = destination,
                   @email_on_failure = email_on_failure,
                   @file_io = file_io,
                   @filenames = filenames,
                   @final_filename = final_filename,
                   @paper = paper,
                   @url = url
  end

  def upload
    conn = Faraday.new(url: @url) do |faraday|
      faraday.response :json
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.use :gzip
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :net_http
    end

    payload = {
      metadata_filename: 'metadata.json',
      aperta_id: @paper.short_doi,
      files: @filenames.join(','),
      destination: @destination.first,
      journal_code: @paper.journal.doi_journal_abbrev,
      # The archive_filename is not a string but the file itself.
      archive_filename: Faraday::UploadIO.new(@file_io, '')
    }
    response = conn.post("/api/deliveries") do |request|
      request.body = payload
    end
  end
end
