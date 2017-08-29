class RouterUploadStatusWorker
  include Sidekiq::Worker

  # retry 12 times every 10 seconds, and don't add failed jobs to the dead job queue
  sidekiq_options retry: 12, dead: false
  sidekiq_retry_in do |count|
    10
  end

  sidekiq_retries_exhausted do |msg|
    export_delivery = TahiStandardTasks::ExportDelivery.find(msg['args'].first)
    export_delivery.delivery_failed!(msg['error_message'])
  end

  def perform(export_delivery_id)
    export_delivery = TahiStandardTasks::ExportDelivery.find(export_delivery_id)

    if export_delivery.service_id.present?
      response = router_connection.get("/api/deliveries/" + export_delivery.service_id)
      result = {  job_status: response.body["job_status"],
                  job_status_description: response.body["job_status_details"] }
    else
      result = {  job_status: "UNKNOWN",
                  job_status_description: "No service ID stored" }
    end

    case result[:job_status]
    when "PENDING"
      raise RouterUploaderService::StatusError, "Time out waiting for export service"
    when "SUCCESS"
      export_delivery.delivery_succeeded!
    else
      export_delivery.delivery_failed!(result['job_status_description'])
    end
  end
end

def router_connection
  Faraday.new(url: TahiEnv.router_url) do |faraday|
    faraday.response :json
    faraday.request  :url_encoded
    faraday.use Faraday::Response::RaiseError
    faraday.adapter :net_http
  end
end
