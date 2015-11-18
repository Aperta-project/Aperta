require 'rails_helper'
require 'fake_ftp'
require 'net/ftp'

describe FtpServices::FtpService do
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
      filesize = File.size(filepath)
      service = FtpServices::FtpService.new(
        host: '127.0.0.1',
        passive_mode: true,
        user: 'user',
        password: 'password',
        port: 21212,
        filename: filename,
        file_path: Rails.root.join('public', 'images', 'cat-scientists-3.jpg')
      )
      service.upload

    	expect(@server.files).to include(filename)
    end
  end

  describe "#connect_to_server" do
    it "successfully connects to a server with correct credentials" do
      filename = 'test.jpg'
      filepath = Rails.root.join('public', 'images', 'cat-scientists-3.jpg')
      filesize = File.size(filepath)
      service = FtpServices::FtpService.new(
        host: '127.0.0.1',
        passive_mode: true,
        user: 'user',
        password: 'password',
        port: 21212,
        filename: filename,
        file_path: Rails.root.join('public', 'images', 'cat-scientists-3.jpg')
      )
      service.connect_to_server
      expect(service.last_response_code).to eq("200")
    end
  end
end
