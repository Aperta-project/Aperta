require 'rails_helper'

describe SalesforceServices::API do
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    @api = SalesforceServices::API

    VCR.use_cassette("salesforce_instantiate_client") do
      @client = @api.client
    end
  end

  describe "#initialize" do
    it "instantiates a Salesforce client" do
      expect(@client.class).to eq Databasedotcom::Client
    end
  end

  describe "#create_manuscript" do
    it "returns a Salesforce Manuscript__c object" do
      VCR.use_cassette("salesforce_create_manuscript") do
        @manuscript = @api.create_manuscript(paper_id: paper.id)
      end
      expect(@manuscript.class).to eq Manuscript__c
    end
  end
  describe "#update_manuscript" do
    it "updates a Salesforce Manuscript__c object" do
      with_valid_salesforce_credentials do
      end
    end
  end
end
