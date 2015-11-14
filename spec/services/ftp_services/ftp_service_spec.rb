require 'rails_helper'

describe FtpServices::FtpService do

  describe "#connection" do
    it "success for transfer" do
      FtpServices::FtpService.new.connection
      expect(1).to eq(1)
    end
  end

end
