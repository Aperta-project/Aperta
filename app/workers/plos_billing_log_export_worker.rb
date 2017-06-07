# PLOS Billing: no longer a fickle rake task but a confident sidekiq job.
class PlosBillingLogExportWorker
  include Sidekiq::Worker
  # twelve retires is at most 6 hours
  sidekiq_options retry: 12

  def perform
    date = Time.zone.now.utc.days_ago(1).beginning_of_day
    # if its retrying we dont want to create a new report
    report = BillingLogReport.first_or_create!(from_date: date)
    # if retrying don't upload to S3 again
    report.save_and_send_to_s3! unless report.csv_file.file
    if BillingFTPUploader.new(report).upload
      report.papers_to_process.each do |paper|
        Activity.create(
          feed_name: "forensic",
          activity_key: "plos_billing.ftp_uploaded",
          subject: paper,
          message: 'Billing uploaded to FTP Server'
        )
      end
    end
  end
end
