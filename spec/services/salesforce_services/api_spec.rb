require 'rails_helper'

describe SalesforceServices::API do
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    @api = SalesforceServices::API
    #expect(@api).to receive(:has_valid_creds?).and_return(true)

    VCR.use_cassette("salesforce_instantiate_client") do
      @client = @api.client
    end
  end

  describe "#client" do
    context "when valid credentials are present" do
      it "instantiates a Salesforce client" do
        expect(@client.class).to eq Databasedotcom::Client
      end
    end

    context "returns nil and logs message when valid credentials are not present" do
      it "instantiates a Salesforce client" do
        expect(SalesforceServices::API).to receive(:has_valid_creds?).and_return(false)
        expect(SalesforceServices::API.get_client).to eq(nil)  #bypasses memoization
      end
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
    it "Fails silently with log message when there is no client" do
      expect(SalesforceServices::API).to receive(:client).and_return(nil)
      expect(Paper).not_to receive(:find)
      SalesforceServices::API.find_or_create_manuscript(paper_id: paper.id)
    end

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

  describe "#has_valid_creds?" do
    it "returns true when all credentials are set to something that is not :not_set" do
      Rails.configuration.salesforce_host          = :foo
      Rails.configuration.salesforce_client_id     = :foo
      Rails.configuration.salesforce_client_secret = :foo
      Rails.configuration.salesforce_username      = :foo
      Rails.configuration.salesforce_password      = :foo

      expect( SalesforceServices::API.has_valid_creds?).to be(true)
    end

    it "returns false if any credentials are not_set" do
      Rails.configuration.salesforce_host = :not_set
      expect( SalesforceServices::API.has_valid_creds?).to be(false)
    end
  end

end
