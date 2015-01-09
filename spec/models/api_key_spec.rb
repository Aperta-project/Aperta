require 'rails_helper'

describe ApiKey do
  describe "#generate_access_token" do

    it "returns a random access token" do
      api_key = ApiKey.create!
      expect(api_key.access_token).to_not be_nil
      expect(api_key.access_token.length).to eq(32)
    end

    context "when the randomly generated token is present" do
      before do
        ApiKey.create!.update_attribute :access_token, 'duplicate_token'
        allow(SecureRandom).to receive(:hex).and_return('duplicate_token', 'something_unique')
      end

      it "will create another token if there exists a duplicate" do
        expect(SecureRandom).to receive(:hex).twice
        ApiKey.create!
      end
    end

  end
end
