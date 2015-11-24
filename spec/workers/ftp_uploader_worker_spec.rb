require 'rails_helper'
require 'fake_ftp'
require 'net/ftp'

describe FtpUploaderWorker do
  before(:each) do
    @server = FakeFtp::Server.new(21212, 21213)
    @server.start
  end

  after(:each) do
    @server.stop
  end

  describe "#upload" do
    it "successfully transfers a file to a ftp server" do
      filename = 'test.jpg'
      filepath = Rails.root.join('public', 'images', 'cat-scientists-3.jpg')
      FtpUploaderWorker.new.perform(
        host: '127.0.0.1',
        passive_mode: true,
        user: 'user',
        password: 'password',
        port: 21212,
        filename: filename,
        filepath: filepath
      )
      expect(@server.files).to include(filename)
    end

    it "raises an error if filepath is missing" do
      filename = 'test.jpg'
      expect {FtpUploaderWorker.new.perform(
        host: '127.0.0.1',
        passive_mode: false,
        user: 'user',
        password: 'password',
        port: 21212,
        filename: filename
      )}.to raise_error(StandardError, "Filepath is required")
      expect(@server.files).not_to include(filename)
    end

    it "raises an error if final filename is missing" do
      filename = 'test.jpg'
      filepath = Rails.root.join('public', 'images', 'cat-scientists-3.jpg')
      expect {FtpUploaderWorker.new.perform(
        host: '127.0.0.1',
        passive_mode: false,
        user: 'user',
        password: 'password',
        port: 21212,
        filepath: filepath
      )}.to raise_error(StandardError, "Final filename is required")
      expect(@server.files).not_to include(filename)
    end
  end
end
