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
          host: '127.0.0.1',
          passive_mode: true,
          user: 'user',
          password: 'password',
          port: 21_212,
          file_io: file_io,
          final_filename: final_filename
        ).upload
      end
      expect(@server.files).to include(final_filename)
    end

    it 'raises an error if file_io is missing' do
      final_filename = 'test.jpg'
      expect do
        FtpUploaderService.new(
          host: '127.0.0.1',
          passive_mode: false,
          user: 'user',
          password: 'password',
          port: 21_212,
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
            host: '127.0.0.1',
            passive_mode: true,
            user: 'user',
            password: 'password',
            port: 21_212,
            file_io: file_io
          ).upload
        end
      end.to raise_error(StandardError, 'final_filename is required')
      expect(@server.files).not_to include(final_filename)
    end
  end
end
