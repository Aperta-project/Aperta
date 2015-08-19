require 'rails_helper'

describe SalesforceServices::API do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:api) {
    VCR.use_cassette("salesforce_instantiate_client") do
      SalesforceServices::API.instance
    end
  }

  describe "#initialize" do
    it "instantiates a Salesforce client" do
      expect(api.client.class).to eq Databasedotcom::Client
    end
  end

  describe "#create_manuscript" do
    before do
      VCR.use_cassette("salesforce_create_manuscript") do
        @manuscript = api.create_manuscript(paper: paper)
      end
    end

    it "returns a Salesforce Manuscript__c object" do
      expect(@manuscript.class).to eq Manuscript__c
    end
  end
end
