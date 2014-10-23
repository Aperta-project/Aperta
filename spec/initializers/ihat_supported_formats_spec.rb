require 'spec_helper'

describe IhatSupportedFormats do
  describe ".call" do
    context "when the IHAT_URL is present" do
      it "makes a request to the URL" do
        ENV['IHAT_URL'] = "something"
        response = double('response', body: "blah")
        expect(Faraday).to receive(:get).with(ENV['IHAT_URL']).and_return(response)
        IhatSupportedFormats.call
      end

      context "when connection fails" do
        it "warns unable to connect" do
          VCR.use_cassette('ihat_404') do
            ENV['IHAT_URL'] = "http://examplethatdoesntexistyet.com"
            response = double('response', body: "blah")
            expect(Rails.logger).to receive(:warn).with("Unable to connect to http://examplethatdoesntexistyet.com")
            IhatSupportedFormats.call
          end
        end
      end

      context "when the url is garbage" do
        it "raises an error" do
          VCR.use_cassette('ihat_404') do
            ENV['IHAT_URL'] = "Blah Blah"
            response = double('response', body: "blah")
            expect {
              IhatSupportedFormats.call
            }.to raise_error(URI::InvalidURIError)
          end
        end
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
