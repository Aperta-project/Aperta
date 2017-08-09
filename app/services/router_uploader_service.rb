class RouterUploaderService
  include UrlBuilder
  class APIError < StandardError; end

  def initialize(destination:,
                 email_on_failure:,
                 file_io:,
                 filenames:,
                 final_filename:,
                 paper:,
                 url:,
                 export_delivery_id:)
    @destination      = destination,
    @email_on_failure = email_on_failure,
    @file_io          = file_io,
    @filenames        = filenames,
    @final_filename   = final_filename,
    @paper            = paper,
    @url              = url,
    @export_delivery    = TahiStandardTasks::ExportDelivery.find(export_delivery_id)
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
    @export_delivery.service_id = response.body["job_id"]
    @export_delivery.save
  end

  def self.check_status(export_delivery_id, router_url: TahiEnv.router_url)
    @export_delivery = TahiStandardTasks::ExportDelivery.find(export_delivery_id)

    conn = Faraday.new(url: router_url) do |faraday|
      faraday.response :json
      faraday.request  :url_encoded
      faraday.use Faraday::Response::RaiseError
      faraday.adapter :net_http
    end
    if @export_delivery.service_id.present?
      response = conn.get("/api/deliveries/" + @export_delivery.service_id)
      return {  job_status: response.body["job_status"],
                job_status_description: response.body["job_status_details"] }
    else
      return {  job_status: "UNKNOWN",
                job_status_description: "No service ID stored" }
    end
  end
end
