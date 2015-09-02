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
      VCR.use_cassette("salesforce_create_manuscript") do
        @manuscript = @api.create_manuscript(paper_id: paper.id)
      end
      VCR.use_cassette("salesforce_update_manuscript") do
        @manuscript = @api.update_manuscript(paper_id: paper.id)
      end

      expect(@manuscript.class).to eq Manuscript__c
    end
  end

  describe "#find_or_create_manuscript" do
    it "calls create when salesforce_manuscript_id is not present" do
      expect(paper.salesforce_manuscript_id).to be_nil
      expect(SalesforceServices::API).to receive(:create_manuscript).and_return(true)
      SalesforceServices::API.find_or_create_manuscript(paper_id: paper.id)
    end

    it "calls update when salesforce_manuscript_id is present" do
      paper.update_attribute(:salesforce_manuscript_id, "foo")
      expect(paper.salesforce_manuscript_id).to be_truthy
      expect(SalesforceServices::API).to receive(:update_manuscript).and_return(true)
      SalesforceServices::API.find_or_create_manuscript(paper_id: paper.id)
    end

  end
end

describe SalesforceServices::API do
  describe "#create_billing_and_pfa_case" do

    let(:paper) { FactoryGirl.create(:paper) }

    it "creates and returns a salesforce case object" do
      #delete_vcr_file  "salesforce_create_billing_and_pfa"

      VCR.use_cassette("salesforce_instantiate_client") do
        @api = SalesforceServices::API
        @api.client
      end

      VCR.use_cassette("salesforce_create_billing_and_pfa") do
        @kase = @api.create_billing_and_pfa_case(paper_id: paper.id)
        expect(@kase.class).to eq Case
        expect(@kase.persisted?).to eq true
      end

    end
  end
end

def delete_vcr_file(file)
  file = "spec/fixtures/vcr_cassettes/#{file}.yml"
  if File.exists?(file)
    ap "deleting #{file}" if File.delete(file) 
  end
end
