require 'spec_helper'

describe FormatsController, type: :controller do
  context "with supported formats" do
    before(:all) do
      @original_supported_formats = Tahi::Application.config.ihat_supported_formats
      VCR.use_cassette(:ihat_supported_formats) do
        IhatSupportedFormats.call
      end
    end

    after(:all) do
      Tahi::Application.config.ihat_supported_formats = @original_supported_formats
    end

    before do
      get :index
    end

    it "returns json" do
      expect(response.content_type).to eq("application/json")
    end

    it "returns 200" do
      expect(response).to be_successful
    end

    it "returns supported formats" do
      json_response = JSON.parse response.body
      expect(json_response['export_formats'].first).to have_key 'format'
    end
  end
end
