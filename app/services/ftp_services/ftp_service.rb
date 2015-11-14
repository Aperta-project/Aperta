module FtpServices
  class FtpService
    require 'net/ftp'

    def connection
      ftp = Net::FTP.new(ENV['FTP_HOST'])
      ftp.passive = true
      ftp.login(user = ENV['FTP_USER'], passwd = ENV['FTP_PASSWORD'])
      ftp.chdir('test')
      count = 0
      ftp.putbinaryfile(File.new(Rails.root.join('public', 'images', 'cat-scientists-3.jpg')), 'test.jpg', 100000) do |block|
        count += 100
        puts "#{count} kilobytes uploaded"
      end
      ftp.last_response
      ftp.last_response_code
      ftp.close
    end
  end
end
