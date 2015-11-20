class FtpUploaderWorker
  include Sidekiq::Worker
  require 'net/ftp'
  class FtpTransferError < StandardError; end;

  def perform(host: ENV['FTP_HOST'], passive_mode: true, user: ENV['FTP_USER'], password: ENV['FTP_PASSWORD'], port: 21, file_path: nil, filename: nil)
    @host = host
    @mode = passive_mode
    @user = user
    @password = password
    @port = port
    @file_path = file_path
    @final_filename = filename

    connect_to_server
    enter_packages_directory
    upload_to_temporary_file

    tmp_file = "temp_#{@final_filename}"
    begin
      if @ftp.last_response_code == "226"
        @ftp.rename("temp_#{@final_filename}", @final_filename)
        Rails.logger.info 'Transfer successful'
        return true
      else
        raise FtpTransferError, "FTP Transfer failed with this response: #{@ftp.last_response}"
        return false
      end
    ensure
      @ftp.delete(tmp_file) if @ftp.nlst.include?(tmp_file)
    end

    @ftp.close
  end

  def last_response_code
    @ftp.last_response_code
  end

  private
  def connect_to_server
    @ftp = Net::FTP.new
    @ftp.connect(@host, @port)
    @ftp.passive = @mode
    @ftp.login(user = @user, passwd = @password)
  end

  def enter_packages_directory
    remote_directories = @ftp.nlst
    @ftp.mkdir('packages') unless remote_directories.index('packages')
    @ftp.chdir('packages')
  end

  def upload_to_temporary_file
    @count = 0
    temporary_name = "temp_#{@final_filename}"
    @ftp.putbinaryfile(File.new(@file_path), temporary_name, 1000) do |block|
      @count += 1000
    end
  end
end
