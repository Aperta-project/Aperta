class RouterUploadStatusWorker
  include Sidekiq::Worker

  # retry 12 times every 10 seconds, and don't add failed jobs to the dead job queue
  sidekiq_options retry: 12, dead: false
  sidekiq_retry_in { 10.seconds }

  sidekiq_retries_exhausted do |msg|
    export_delivery = TahiStandardTasks::ExportDelivery.find(msg['args'].first)
    export_delivery.delivery_failed!('Time out waiting for export service')
  end

  def perform(export_delivery_id)
    export_delivery = TahiStandardTasks::ExportDelivery.find(export_delivery_id)
    service = TahiStandardTasks::ExportService.new export_delivery: export_delivery
    result = service.export_status

    case result[:job_status]
    when "PENDING"
      raise TahiStandardTasks::ExportService::StatusError, "Job pending"
    when "SUCCESS"
      export_delivery.delivery_succeeded!
      # check for published status (for preprints only)
      RouterPublishStatusWorker.perform_in(1.hour, export_delivery.id) if export_delivery.destination == 'preprint'
    else
      export_delivery.delivery_failed!(result[:job_status_description])
    end
  end
end
