require 'rails_helper'

describe CloudServices::S3Service do

  describe "#connection" do
    it "return a Fog S3 object" do
      s3_via_fog = CloudServices::S3Service.new.connection
      expect(s3_via_fog.class.to_s).to include("Fog::Storage::AWS")
    end
  end

end
