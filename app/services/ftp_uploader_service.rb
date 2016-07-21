# Generic wrapper for Net::FTP
class FtpUploaderService
  require 'net/ftp'
  require 'uri'
  class FtpTransferError < StandardError; end;
  TRANSFER_COMPLETE = '226'

  def initialize(
    file_io: nil,
    final_filename: nil,
    passive_mode: true,
    url: TahiEnv.apex_ftp_url
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
    @user = ftp_url.user
  end

  def upload
    fail FtpTransferError, 'file_io is required' if @file_io.blank?
    fail FtpTransferError, 'final_filename is required' if @final_filename.blank?

    begin
      @ftp = Net::FTP.new
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
    AdhocMailer.delay.send_adhoc_email(
      transfer_failed,
      transfer_failed + ": #{@ftp.last_response}. Please try to upload again.",
      User.joins(:old_roles).where('old_roles.kind' => 'admin')
    )
  end

  def connect_to_server
    @ftp.connect(@host, @port)
    @ftp.passive = @passive_mode
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
      @ftp.putbinaryfile(@file_io, temp_name, 1000)
    end
  end
end
