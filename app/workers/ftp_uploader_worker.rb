class FtpUploaderWorker
  include Sidekiq::Worker
  require 'net/ftp'
  class FtpTransferError < StandardError; end;

  def perform(host: ENV['FTP_HOST'], passive_mode: true, user: ENV['FTP_USER'], password: ENV['FTP_PASSWORD'], port: 21, filepath: nil, filename: nil)
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
      if @ftp.last_response_code == '226'
        @ftp.rename(tmp_file, @final_filename)
        Rails.logger.info 'Transfer successful'
        return true
      else
        fail FtpTransferError, "FTP Transfer failed with this response: #{@ftp.last_response}"
      end
    ensure
      @ftp.delete(tmp_file) if @ftp.nlst.include?(tmp_file)
      @ftp.close
    end
  end

  private

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
