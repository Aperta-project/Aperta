# This service is used to FTP the BillingLogReport to billing ftp server.
class BillingFTPUploader < FtpUploaderService
  def initialize(billing_log_report)
    @billing_log_report = billing_log_report
  end

  def upload
    if TahiEnv.billing_ftp_enabled?
      load_ftp_settings
      super
    else
      Rails.logger.info "Billing FTP is not enabled."
    end
  end

  def load_ftp_settings
    @host = TahiEnv.billing_ftp_host
    @passive_mode = true
    @user = TahiEnv.billing_ftp_user
    @password = TahiEnv.billing_ftp_password
    @port = TahiEnv.billing_ftp_port
    @file_io = @billing_log_report.csv_file.url
    @final_filename = final_filename
    @directory = TahiEnv.billing_ftp_dir
  end

  def final_filename
    upload_datetime = Time.zone.now.strftime "%Y%m%d-%H%M"
    "aperta-billing-#{upload_datetime}.csv"
  end
end
