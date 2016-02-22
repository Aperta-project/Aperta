require 'rails_helper'

describe SalesforceServices::API do
  let(:paper) { FactoryGirl.create(:paper) }

  before do
    @api = SalesforceServices::API

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
  end

  describe "salesforce_active" do
    context "DATEBASEDOTCOM_DISABLED is set to true" do
      before do
        ENV["DATEBASEDOTCOM_DISABLED"] = 'true'
      end
      after do
        ENV["DATEBASEDOTCOM_DISABLED"] = nil
      end

      it "salesforce_active returns false" do
        expect(SalesforceServices::API.salesforce_active).to eq(false)
      end
    end

    context "DATEBASEDOTCOM_DISABLED is nil" do
      before do
        ENV["DATEBASEDOTCOM_DISABLED"] = nil
      end

      it "creates the salesforce client" do
        expect(SalesforceServices::API).to receive(:client)
        expect(SalesforceServices::API.salesforce_active).to eq(true)
      end
    end

  end

  describe "#create_manuscript" do
    it "calls create on a Salesforce Manuscript__c object" do
      mock_manuscript = instance_double("Manuscript__c", Id: 'sfdc')
      expect(Manuscript__c).to receive(:create).and_return(mock_manuscript)
      manuscript = @api.create_manuscript(paper_id: paper.id)
      expect(manuscript).to eq mock_manuscript
    end
  end

  describe "#update_manuscript" do
    let(:paper) do
      FactoryGirl.create(:paper, salesforce_manuscript_id: "sfdc_id_1")
    end
    it "finds then updates a Salesforce Manuscript__c object" do
      mock_manuscript = instance_double("Manuscript__c", Id: 'sfdc')
      expect(Manuscript__c).to receive(:find)
        .with(paper.salesforce_manuscript_id)
        .and_return(mock_manuscript)
      expect(mock_manuscript).to receive(:update_attributes)
      manuscript = @api.update_manuscript(paper_id: paper.id)
      expect(manuscript).to eq mock_manuscript
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

  describe '#create_billing_and_pfa_case' do
    it 'creates and returns a salesforce case object' do
      task_params = {
        title: 'Billing',
        type: 'PlosBilling::BillingTask',
        paper_id: paper.id,
        old_role: 'author'
      }
      paper = FactoryGirl.create(:paper_with_task, :with_integration_journal, :with_creator, task_params: task_params)

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

def delete_vcr_file(file) # useful when writing new specs that require vcr, and need the http request need to be made multiple times until correct
  file = "spec/fixtures/vcr_cassettes/#{file}.yml"
  if File.exists?(file)
    ap "deleting #{file}" if File.delete(file)
  end
end
