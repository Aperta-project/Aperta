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
  end
end
