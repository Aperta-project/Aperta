require "rails_helper"

describe TahiPusher::Config do
  let(:config) { TahiPusher::Config }

  describe ".as_json" do
    it "serializes to JSON" do
      expect(config.as_json).to be_a(Hash)
    end
  end
end
