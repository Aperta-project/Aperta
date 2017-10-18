class RouterUploaderService
  include UrlBuilder
  class APIError < StandardError; end
  class StatusError < StandardError; end

  def initialize(destination:,
                 email_on_failure:,
                 file_io:,
                 filenames:,
                 final_filename:,
                 paper:,
                 url:,
                 export_delivery_id:)
    @destination = destination,
    @email_on_failure = email_on_failure,
    @file_io          = file_io,
    @filenames        = filenames,
    @final_filename   = final_filename,
    @paper            = paper,
    @url              = url,
    @export_delivery = TahiStandardTasks::ExportDelivery.find(export_delivery_id)
  end

  def upload
    # execute initial article router service POST request
    response = router_connection.post("/api/deliveries") do |request|
      request.body = router_payload
    end

    # save job id and poll downstream article ingestion job asynchronously
    @export_delivery.service_id = response.body["job_id"]
    @export_delivery.save!
    RouterUploadStatusWorker.perform_in(10.seconds, @export_delivery.id)
  end

  def router_connection
    Faraday.new(url: @url) do |faraday|
      faraday.response :json
      faraday.request :multipart
      faraday.request :url_encoded
      faraday.use :gzip
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :net_http
    end
  end

  def aperta_id
    @paper.id.to_s.rjust(7, '0')
  end

  def router_payload
    {
      metadata_filename: 'metadata.json',
      aperta_id: aperta_id,
      files: @filenames.join(','),
      destination: @destination.first,
      journal_code: @paper.journal.doi_journal_abbrev,
      # The archive_filename is not a string but the file itself.
      archive_filename: Faraday::UploadIO.new(@file_io, '')
    }
  end
end
