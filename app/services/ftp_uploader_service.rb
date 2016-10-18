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
      raise FtpTransferError, "FTP Transfer failed: #{@ftp.last_response}"
    end
  rescue Exception => e
    notify_admin(e)
    raise
  ensure
    if @ftp
      @ftp.delete(tmp_file) if @ftp.nlst.include?(tmp_file)
      @ftp.close
    end
  end

  private

  def notify_admin(exception)
    transfer_failed = "FTP Transfer failed for #{@final_filename}"
    transfer_error = transfer_failed
    transfer_error += ": #{@ftp.last_response}" if @ftp
    transfer_error += "\n" + @error_detail if @error_detail
    transfer_error += <<-STR.strip_heredoc
      \n\nIf this was a manual attempt please try to upload again. Otherwise,
      please contact the Aperta support team.
    STR
    if exception
      transfer_error += "\nException Detail:\n" + exception.message
      transfer_error += "\nBacktrace:\n" + exception.backtrace.join("\n")
    end
    Rails.logger.warn(transfer_error)
    Bugsnag.notify(transfer_error)
    GenericMailer.delay.send_email(
      subject: transfer_failed,
      body: transfer_error,
      to: @email_on_failure
    )
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
