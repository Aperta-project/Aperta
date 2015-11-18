module FtpServices
  class FtpService
    require 'net/ftp'

    def initialize(params={})
      @host = params[:host] || ENV['FTP_HOST']
      @mode = params[:passive_mode] || true
      @user = params[:user] || ENV['FTP_USER']
      @password = params[:password] || ENV['FTP_PASSWORD']
      @port = params[:port] || 21
      @file_path = params[:file_path]
      @final_filename = params[:filename]
    end

    def upload
      connect_to_server
      enter_packages_directory
      upload_to_temporary_file
      if @ftp.last_response_code == "226"
        @ftp.rename("temp_#{@final_filename}", @final_filename)
        puts "Transfer successful"
      else
        puts "Transfer failed. Please try again."
      end
      @ftp.close
    end

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
      @ftp.putbinaryfile(File.new(@file_path), temporary_name, 100000) do |block|
        @count += 100
        puts "#{@count} kilobytes uploaded"
      end
    end

    def last_response_code
      @ftp.last_response_code
    end
  end
end
