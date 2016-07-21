# This service is used to FTP the BillingLogReport to billing ftp server.
class BillingFTPUploader < FtpUploaderService
  def initialize(billing_log_report)
    @billing_log_report = billing_log_report
    super(
      file_io: @billing_log_report.csv,
      final_filename: timestamped_filename,
      url: TahiEnv.billing_ftp_url
    )
  end

  def upload
    if TahiEnv.billing_ftp_enabled?
      super
    else
      Rails.logger.info "Billing FTP is not enabled."
    end
  end

  def timestamped_filename
    upload_datetime = Time.zone.now.strftime "%Y%m%d-%H%M"
    "aperta-billing-#{upload_datetime}.csv"
  end

  private

  def notify_admin
    transfer_error = "Billing FTP Transfer failed for #{@final_filename}: "\
      "#{@ftp.last_response}. "\
      "#{@billing_log_report.papers_to_process.count} papers with the"\
      "following IDs were not sent to billing: #{paper_ids}"
    Bugsnag.notify(transfer_error)
  end

  def paper_ids
    @billing_log_report.papers_to_process.map(&:id)
  end
end
