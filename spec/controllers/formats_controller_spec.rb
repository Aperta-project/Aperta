require 'rails_helper'

describe FormatsController, type: :controller do
  context "with supported formats" do
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
      expect(json_response['export_formats']).to be_an Array
      expect(json_response['export_formats']).to be_present
    end
  end
end
