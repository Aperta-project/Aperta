require 'spec_helper'

describe ApiKey do
  describe "#generate_access_token" do

    it "returns a random access token" do
      api_key = ApiKey.create!
      expect(api_key.access_token).to_not be_nil
      expect(api_key.access_token.length).to eq(32)
    end

    context "when the randomly generated token is present" do
      it "will create another unique token" do
        token1 = ApiKey.create!
        token1.update_attribute :access_token, 'duplicate_token'

        allow(SecureRandom).to receive(:hex) do
          ['duplicate_token', 'new_token'].sample
        end

        token2 = ApiKey.create!
      end
    end
  end
end
