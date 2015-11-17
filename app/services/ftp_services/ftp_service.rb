module FtpServices
  class FtpService
    require 'net/ftp'

    def connection
      ftp = Net::FTP.new(ENV['FTP_HOST'])
      ftp.passive = true
      ftp.login(user = ENV['FTP_USER'], passwd = ENV['FTP_PASSWORD'])
      remote_directories = ftp.nlst
      ftp.mkdir('packages') unless remote_directories.index('packages')
      ftp.chdir('packages')
      count = 0
      filename = "test.jpg"
      temporary_name = "temp_#{filename}"
      ftp.putbinaryfile(File.new(Rails.root.join('public', 'images', 'cat-scientists-3.jpg')), temporary_name, 100000) do |block|
        count += 100
        puts "#{count} kilobytes uploaded"
      end
      if ftp.last_response_code == "226"
        ftp.rename(temporary_name, filename)
        puts "Transfer successful"
      else
        puts "Transfer failed. Please try again."
      end
      ftp.close
    end
  end
end
