# PLOS Billing: no longer a fickle rake task but a confident sidekiq job.
class PlosBillingLogExportWorker
  include Sidekiq::Worker
  # twelve retires is at most 6 hours
  sidekiq_options retry: 12

  def perform
    report = BillingLogReport.create!
    report.save_and_send_to_s3! unless report.csv_file.file
    return unless BillingFTPUploader.new(report).upload
    report.papers_to_process.each do |paper|
      Activity.create(
        feed_name: "forensic",
        activity_key: "plos_billing.ftp_uploaded",
        subject: paper,
        message: BillingLogReport::ACTIVITY_MESSAGE
      )
    end
  end
end
