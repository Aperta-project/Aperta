require 'rails_helper'

describe UrlBuilder do
  # mixed in url_builder concern
  let(:model){ class FakeModel; include UrlBuilder; end; }

  describe "#url_for" do
    it "will generate a url for a valid resource path" do
      expect(Rails.configuration.action_mailer.default_url_options[:host]).to eq("www.example.com")
      expect(model.new.url_for(:root)).to eq("http://www.example.com/")
    end

    it "allows routing options to be overridden" do
      options = { host: "foo.com", port: "8080" }
      expect(model.new.url_for(:root, options)).to eq("http://foo.com:8080/")
    end
  end
end
