require 'rails_helper'
require 'fake_ftp'

describe FtpUploaderService do
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
      File.open(filepath) do |file_io|
        FtpUploaderService.new(
          passive_mode: true,
          file_io: file_io,
          final_filename: final_filename,
          url: 'ftp://user:password@127.0.0.1:21212/my_dir'
        ).upload
      end
      expect(@server.files).to include(final_filename)
    end

    it 'raises an error if file_io is missing' do
      final_filename = 'test.jpg'
      expect do
        FtpUploaderService.new(
          passive_mode: false,
          url: 'ftp://user:password@127.0.0.1:21212/my_dir',
          final_filename: final_filename
        ).upload
      end.to raise_error(StandardError, 'file_io is required')
      expect(@server.files).not_to include(final_filename)
    end

    it 'raises an error if final filename is missing' do
      final_filename = 'test.jpg'
      filepath = Rails.root.join('public', 'images', 'cat-scientists-3.jpg')
      expect do
        File.open(filepath) do |file_io|
          FtpUploaderService.new(
            passive_mode: true,
            url: 'ftp://user:password@127.0.0.1:21212/my_dir',
            file_io: file_io
          ).upload
        end
      end.to raise_error(StandardError, 'final_filename is required')
      expect(@server.files).not_to include(final_filename)
    end

    it 'notifies admins upon FTP failure' do
      final_filename = 'test.jpg'
      emails = ['adminA@example.com', 'adminB@example.com']
      uploader = FtpUploaderService.new(
        passive_mode: true,
        file_io: 'present',
        final_filename: final_filename,
        url: 'ftp://user:password@127.0.0.1:21212/my_dir',
        email_on_failure: emails
      )
      email_contents = emails << final_filename

      allow(uploader).to receive(:connect_to_server).and_raise(FtpUploaderService::FtpTransferError)

      expect do
        uploader.upload
      end.to raise_error(Net::FTPConnectionError, 'not connected')

      expect(Sidekiq::Extensions::DelayedMailer.jobs.first["args"].last).to include(*email_contents)
    end
  end
end
