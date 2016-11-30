require 'rails_helper'

describe IhatJobRequest do
  describe '.recipe_name' do
    context "valid input/output formats" do
      it "finds a matching recipe" do
        expect(
          IhatJobRequest.recipe_name(from_format: "doc", to_format: "html")
        ).to eq("doc_to_html")
      end

      it 'it downcases formats' do
        expect(
          IhatJobRequest.recipe_name(from_format: "DOCX", to_format: "html")
        ).to eq("docx_to_html")
      end
    end

    context "invalid input/output formats" do
      it "throws an error" do
        expect {
          IhatJobRequest.recipe_name(from_format: "INVALID", to_format: "html")
        }.to raise_error(/unable to find/i)
      end
    end
  end

  describe '#build_ihat_callback_url' do
    # Use around to ensure we don't mess up the environment for other tests
    around do |example|
      ClimateControl.modify(IHAT_CALLBACK_URL: nil) do
        example.run
      end
    end

    it <<-EOT do
      returns the callback URL for ihat to use to talk to this instance
      of the application. This URL is how ihat is able to tell Aperta
      the status of document conversion jobs.
    EOT
      url = IhatJobRequest.build_ihat_callback_url
      expect(URI.parse(url)).to be_kind_of(URI)
    end

    context 'and the IHAT_CALLBACK_URL env var is not set' do
      before { ENV.delete('IHAT_CALLBACK_URL') }

      context 'and FORCE_SSL env var is not set' do
        before { ENV.delete('FORCE_SSL') }

        it 'returns an HTTPS url built using default rails route config' do
          expect(IhatJobRequest.build_ihat_callback_url)
            .to eq('https://test.host/api/ihat/jobs')
        end
      end

      context 'and FORCE_SSL env var is set to a truthy value' do
        before { ENV['FORCE_SSL'] = '1' }

        it 'returns an HTTPS url built using default rails route config' do
          expect(IhatJobRequest.build_ihat_callback_url)
            .to eq('https://test.host/api/ihat/jobs')
        end
      end

      context 'and FORCE_SSL env var is set to a falsy value' do
        before { ENV['FORCE_SSL'] = '0' }

        it 'returns an HTTP url built using default rails route config' do
          expect(IhatJobRequest.build_ihat_callback_url)
            .to eq('http://test.host/api/ihat/jobs')
        end
      end
    end

    context 'and the IHAT_CALLBACK_URL env var is set' do
      let(:ihat_callback_url) { 'http://example.com:9999' }
      before { ENV['IHAT_CALLBACK_URL'] = ihat_callback_url }

      it 'uses the env var value as the base URL ignoring rails route config' do
        expect(IhatJobRequest.build_ihat_callback_url)
            .to eq("#{ihat_callback_url}/api/ihat/jobs")
      end
    end
  end
end
