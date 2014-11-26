require 'spec_helper'

describe IhatSupportedFormats do
  before(:all) do
    @original_ihat_url = ENV['IHAT_URL']
  end

  after(:all) do
    ENV['IHAT_URL'] = @original_ihat_url
  end

  describe ".call" do
    context "when the IHAT_URL is present" do
      it "makes a request to the URL and sets ihat_supported_formats" do
        ENV['IHAT_URL'] = "http://localhost:3000"
        VCR.use_cassette('ihat_200_json') do
          IhatSupportedFormats.call
          expect(Tahi::Application.config.ihat_supported_formats).not_to eq 'null'
          expect(Tahi::Application.config.ihat_supported_formats).not_to be_nil
        end
      end

      context "when connection fails" do
        it "warns unable to connect" do
          ENV['IHAT_URL'] = "http://examplethatdoesntexistyet.com"
          expect(Faraday).to receive(:get).with(ENV['IHAT_URL']).and_raise(Faraday::ConnectionFailed.new("stuff"))
          expect(Rails.logger)
          .to receive(:warn)
          .with("Unable to connect to http://examplethatdoesntexistyet.com")
          IhatSupportedFormats.call
        end
      end

      context "when the server returns HTML" do
        it "raises an error" do
          ENV['IHAT_URL'] = "http://www.google.com"
          VCR.use_cassette('ihat_200_html') do
            expect {
              IhatSupportedFormats.call
            }.to raise_error(JSON::ParserError)
          end
        end
      end

      context "when the url is garbage" do
        it "raises an error" do
          ENV['IHAT_URL'] = "Blah Blah"
          expect {
            IhatSupportedFormats.call
          }.to raise_error(URI::InvalidURIError)
        end
      end

      context "when the IHAT_URL isn't present" do
        it "it warns about iHat" do
          ENV['IHAT_URL'] = nil
          expect(Faraday).not_to receive(:get)
          expect(Rails.logger).to receive(:warn).with("ENV['IHAT_URL'] Not set, falling back to default document types…")
          IhatSupportedFormats.call
        end
      end

    end
  end
end
