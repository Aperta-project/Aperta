class RouterPublishStatusWorker
  include Sidekiq::Worker

  # retry 48 times once per hour (2 days total), then send to dead job queue
  sidekiq_options retry: 48
  sidekiq_retry_in { 1.hour }

  def perform(export_delivery_id)
    export_delivery = TahiStandardTasks::ExportDelivery.find(export_delivery_id)
    service = TahiStandardTasks::ExportService.new export_delivery: export_delivery
    result = service.export_status
    Rails.logger.warn("WARNING: Router returned: #{result[:job_status_description]}") if result[:job_status] != 'SUCCESS'
    raise TahiStandardTasks::ExportService::StatusError, "Waiting for preprint published status" unless result[:published_on_prod]
    export_delivery.published_on_prod!
  end
end
