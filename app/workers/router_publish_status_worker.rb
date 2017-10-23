class RouterPublishStatusWorker
  include Sidekiq::Worker

  # retry 48 times once per hour (2 days total), then send to dead job queue
  sidekiq_options retry: 48
  sidekiq_retry_in { 1.hour }

  sidekiq_retries_exhausted do
    Rails.logger.warn("Time out waiting for preprint published status.")
  end

  def perform(export_delivery_id)
    export_delivery = TahiStandardTasks::ExportDelivery.find(export_delivery_id)
    service = RouterService.new(export_delivery)
    result = service.export_status
    Rails.logger.warn(result[:job_status_description]) if result[:job_status] != 'SUCCESS'
    export_delivery.published_on_prod! if result[:published_on_prod]
    raise ExportService::StatusError, "Waiting for preprint published status"
  end
end
