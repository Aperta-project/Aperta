require 'rails_helper'
require 'fake_ftp'

describe FtpUploaderService do
  let(:logger) do
    log = Logger.new(logger_io)
    # override default logger formatter since we don't care what the
    # format for the application is set to, just that we're logging
    # correctly
    log.formatter = lambda do |severity, datetime, progname, msg|
      "#{severity}: #{msg}"
    end
    log
  end

  let(:logger_io) { StringIO.new }
  let(:logged_content) { logger_io.tap(&:rewind).read }

  before(:each) do
    @server = FakeFtp::Server.new(21_212, 21_213)
    @server.start
  end

  after(:each) do
    @server.stop
  end

  describe '#upload' do
    it 'successfully transfers a file to a ftp server' do
      final_filename = 'test.jpg'
      filepath = Rails.root.join('public', 'images', 'cat-scientists-3.jpg')
      Timecop.freeze("2016-11-09 17:38:27 -0500") do
        File.open(filepath) do |file_io|
          uploader = FtpUploaderService.new(
          passive_mode: true,
          file_io: file_io,
          final_filename: final_filename,
          url: 'ftp://user:password@127.0.0.1:21212/my_dir'
          )
          allow(uploader).to receive(:logger).and_return(logger)
          uploader.upload
        end
      end

      expect(logged_content).to match 'INFO: Beginning transfer for test.jpg'
      expect(logged_content).to match 'INFO: FTP connecting to 127.0.0.1: 21212'
      expect(logged_content).to match 'INFO: FTP logging in as user'
      expect(logged_content).to match 'INFO: Beginning transfer to temp location at temp_2016-11-09-223827_test.jpg'
      expect(logged_content).to match 'INFO: Transfer successful for my_dir/test.jpg'
      expect(@server.files).to include(final_filename)
    end

    it 'notifies email list upon FTP failure' do
      final_filename = 'test.jpg'
      emails = ['adminA@example.com', 'adminB@example.com']
      uploader = FtpUploaderService.new(
        passive_mode: true,
        file_io: 'present',
        final_filename: final_filename,
        url: 'ftp://user:password@127.0.0.1:21212/my_dir',
        error_detail: 'optional error detail',
        email_on_failure: emails
      )
      email_contents = emails << final_filename

      allow(uploader).to receive(:logger).and_return(logger)
      allow(uploader).to receive(:connect_to_server).and_raise(FtpUploaderService::FtpTransferError)

      expect do
        uploader.upload
      end.to raise_error(Net::FTPConnectionError, 'not connected')
      expect(logged_content).to match 'INFO: Beginning transfer for test.jpg'
      expect(logged_content).to match 'WARN: FTP Transfer failed for test.jpg'
      expect(logged_content).to match 'optional error detail'
      expect(logged_content).to match 'Exception Detail:'
      expect(logged_content).to match 'FtpUploaderService::FtpTransferError'
      expect(logged_content).to match 'Backtrace:'

      expect(Sidekiq::Extensions::DelayedMailer.jobs.first["args"].last).to include(*email_contents)
    end
  end
end
