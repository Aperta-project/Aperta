class FtpUploaderWorker
  include Sidekiq::Worker
  require 'net/ftp'
  class FtpTransferError < StandardError; end;
  TRANSFER_COMPLETE = '226'

  def perform(host: ENV['FTP_HOST'], passive_mode: true, user: ENV['FTP_USER'], password: ENV['FTP_PASSWORD'], port: 21, filepath: nil, filename: nil)
    fail FtpTransferError, "Filepath is required" if filepath.blank?
    fail FtpTransferError, "Final filename is required" if filename.blank?
    @host = host
    @passive_mode = passive_mode
    @user = user
    @password = password
    @port = port
    @filepath = filepath
    @final_filename = filename

    connect_to_server
    enter_packages_directory
    tmp_file = upload_to_temporary_file

    begin
      if @ftp.last_response_code == TRANSFER_COMPLETE
        @ftp.rename(tmp_file, @final_filename)
        Rails.logger.info 'Transfer successful'
        return true
      else
        notify_admin
        fail FtpTransferError, "FTP Transfer failed with this response: #{@ftp.last_response}"
      end
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
      transfer_failed + ": #{@ftp.last_response}. The background worker will attempt to retry the transfer.",
      User.joins(:roles).where('roles.kind' => 'admin')
    )
  end

  def connect_to_server
    @ftp = Net::FTP.new
    @ftp.connect(@host, @port)
    @ftp.passive = @passive_mode
    @ftp.login(user = @user, passwd = @password)
  end

  def enter_packages_directory
    remote_directories = @ftp.nlst
    @ftp.mkdir('packages') unless remote_directories.index('packages')
    @ftp.chdir('packages')
  end

  def upload_to_temporary_file
    "temp_#{@final_filename}".tap do |temp_name|
      @ftp.putbinaryfile(File.new(@filepath), temp_name, 1000)
    end
  end
end
