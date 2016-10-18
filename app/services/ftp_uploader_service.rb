# Generic wrapper for Net::FTP
class FtpUploaderService
  require 'net/ftp'
  require 'uri'
  class FtpTransferError < StandardError; end;
  TRANSFER_COMPLETE = '226'

  def initialize(
    file_io: nil,
    passive_mode: true,
    final_filename: nil,
    url: TahiEnv.apex_ftp_url,
    email_on_failure: nil,
    error_detail: nil
  )

    ftp_url = URI.parse(url)
    if ftp_url.path.present?
      @directory = ftp_url.path
    else
      @directory = 'packages'
    end

    @file_io = file_io
    @final_filename = final_filename
    @host = ftp_url.host
    @passive_mode = passive_mode
    @password = ftp_url.password
    @port = ftp_url.port || 21
    @user = URI.unescape(ftp_url.user)
    @email_on_failure = email_on_failure
    @error_detail = error_detail
  end

  def upload
    fail FtpTransferError, 'file_io is required' if @file_io.blank?
    fail FtpTransferError, 'final_filename is required' if @final_filename.blank?

    begin
      @ftp = Net::FTP.new
      Rails.logger.info "Beginning transfer for #{@final_filename}"
      connect_to_server
      enter_packages_directory
      tmp_file = upload_to_temporary_file
      if @ftp.last_response_code == TRANSFER_COMPLETE
        begin
          @ftp.delete @final_filename
        rescue Net::FTPPermError
        end
        @ftp.rename(tmp_file, @final_filename)
        Rails.logger.info "Transfer successful for #{@final_filename}"
        return true
      else
        fail FtpTransferError, "FTP Transfer failed: #{@ftp.last_response}"
      end
    rescue IOError, SystemCallError, Net::FTPError, FtpTransferError
      notify_admin
      raise
    ensure
      @ftp.delete(tmp_file) if @ftp.nlst.include?(tmp_file)
      @ftp.close
    end
  end

  private

  def notify_admin
    transfer_failed = "FTP Transfer failed for #{@final_filename}"
    transfer_error = transfer_failed + ": #{@ftp.last_response}."
    transfer_error = transfer_error + "\n" + @error_detail if @error_detail
    GenericMailer.delay.send_email(
      transfer_failed,
      transfer_error + "\nPlease try to upload again.",
      email_on_failure
    )
    Bugsnag.notify(transfer_error)
    Rails.logger.warn(transfer_error)
  end

  def connect_to_server
    Rails.logger.info "FTP connecting to #{@host}: #{@port}"
    @ftp.connect(@host, @port)
    @ftp.passive = @passive_mode
    Rails.logger.info "FTP logging in as #{@user}"
    @ftp.login(@user, @password)
  end

  def enter_packages_directory
    @ftp.chdir(@directory)
  rescue Net::FTPPermError
    Rails.logger.info "Attempting to create ftp directory: #{@directory}"
    @ftp.mkdir(@directory)
    @ftp.chdir(@directory)
  end

  def upload_to_temporary_file
    upload_time = Time.zone.now.strftime "%Y-%m-%d-%H%M%S"
    "temp_#{upload_time}_#{@final_filename}".tap do |temp_name|
      Rails.logger.info "Beginning transfer to temp location at #{temp_name}"
      @ftp.putbinaryfile(@file_io, temp_name, 1000)
    end
  end
end
