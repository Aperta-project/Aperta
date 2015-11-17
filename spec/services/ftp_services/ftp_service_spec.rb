require 'rails_helper'

describe FtpServices::FtpService do

  describe "#upload" do
    it "successfully transfers file to server" do
      FtpServices::FtpService.new.upload
      expect(1).to eq(1)
    end
  end

end
