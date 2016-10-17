# This service is used to FTP the BillingLogReport to billing ftp server.
class BillingFTPUploader
  def initialize(billing_log_report)
    if billing_log_report.nil?
      raise ArgumentError, 'The billing_log_report cannot be nil'
    end
    @billing_log_report = billing_log_report

    emails = Journal
             .staff_admins_for_papers(billing_log_report.papers_to_process)
             .map(&:email)

    @ftp_uploader = FtpUploaderService.new(
      file_io: @billing_log_report.csv,
      final_filename: timestamped_filename,
      url: TahiEnv.billing_ftp_url,
      email_on_failure: emails,
      error_detail: error_detail
    )
  end

  def upload
    if TahiEnv.billing_ftp_enabled?
      @ftp_uploader.upload
    else
      Rails.logger.info "Billing FTP is not enabled."
    end
  end

  def timestamped_filename
    upload_datetime = Time.zone.now.strftime "%Y%m%d-%H%M"
    "aperta-billing-#{upload_datetime}.csv"
  end

  private

  def error_detail
    "#{@billing_log_report.papers_to_process.count} papers with the"\
    " following IDs were not sent to billing: #{paper_ids}"
  end

  def paper_ids
    @billing_log_report.papers_to_process.map(&:id)
  end
end
