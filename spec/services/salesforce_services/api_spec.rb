require 'rails_helper'

RSpec::Matchers.define :be_the_same_time_as do |expected|
  match do |actual|
    expect(expected.to_i).to be_within(10.seconds).of(actual.to_i)
  end
end

describe SalesforceServices::API do
  let(:api) do
    VCR.use_cassette("salesforce_instantiate_client") do
      SalesforceServices::API.instance
    end
  end

  let(:client) { api.client }
  let(:paper) { FactoryGirl.create(:paper) }

  describe ".client" do
    it "returns a Salesforce client" do
      expect(client).to be_kind_of Databasedotcom::Client
    end
  end

  describe ".sync_manuscript" do
    context "and the paper hasn't been synced to Salesforce yet"  do
      before { paper.update_attribute :salesforce_manuscript_id, nil }

      it "creates the Salesforce Manuscript" do
        expect(api).to receive(:create_manuscript).with(paper_id:paper.id)
        SalesforceServices::API.sync_manuscript(paper_id:paper.id)
      end
    end

    context "and the paper has been synced to Salesforce before" do
      before { paper.update_attribute :salesforce_manuscript_id, "foo" }

      it "updates the Salesforce Manuscript" do
        expect(api).to receive(:update_manuscript).with(paper_id:paper.id)
        SalesforceServices::API.sync_manuscript(paper_id:paper.id)
      end
    end
  end

  describe "#create_manuscript", vcr: { cassette_name: "salesforce_create_manuscript" } do
    it "returns a Salesforce Manuscript object" do
      manuscript = api.create_manuscript(paper_id: paper.id)
      expect(manuscript).to be_kind_of Manuscript__c
    end

    it "assigns the salesforce_manuscript_id on the paper" do
      manuscript = api.create_manuscript(paper_id: paper.id)
      expect(paper.reload.salesforce_manuscript_id).to eq(manuscript.Id)
    end

    context "sets attributes on the Salesforce Manuscript object" do
      subject(:salesforce_manuscript){ api.create_manuscript(paper_id: paper.id) }

      it("sets RecordTypeId") do
        expect(salesforce_manuscript.RecordTypeId).to eq "012U0000000E4ASIA0"
      end

      it("sets OwnerId") do
        expect(salesforce_manuscript.OwnerId).to eq client.user_id
      end

      it("sets Editorial_Process_Close__c") do
        expect(salesforce_manuscript.Editorial_Process_Close__c).to be false
      end

      it("sets Display_Technical_Notes__c") do
        expect(salesforce_manuscript.Display_Technical_Notes__c).to be false
      end

      it("sets CreatedByDeltaMigration__c") do
        expect(salesforce_manuscript.CreatedByDeltaMigration__c).to be false
      end

      it("sets Editorial_Status_Date__c to the current time") do
        expect(salesforce_manuscript.Editorial_Status_Date__c.to_time.getutc).to be_the_same_time_as Time.now
      end

      it("sets Revision__c") do
        expect(salesforce_manuscript.Revision__c).to eq "0.0"
      end
    end
  end

  describe "#update_manuscript", vcr: { cassette_name: "salesforce_update_manuscript" } do
    before do
      VCR.use_cassette("salesforce_create_manuscript") do
        api.create_manuscript(paper_id: paper.id)
      end
    end

    let(:salesforce_manuscript) do
      api.update_manuscript(paper_id: paper.id)
    end

    it "returns an updated Salesforce Manuscript object" do
      expect(salesforce_manuscript).to be_kind_of Manuscript__c
    end

    context "updates attributes on the Salesforce Manuscript object" do
      it("sets RecordTypeId") do
        expect(salesforce_manuscript.RecordTypeId).to eq "012U0000000E4ASIA0"
      end

      it("sets OwnerId") do
        expect(salesforce_manuscript.OwnerId).to eq client.user_id
      end

      it("sets Editorial_Process_Close__c") do
        expect(salesforce_manuscript.Editorial_Process_Close__c).to be false
      end

      it("sets Display_Technical_Notes__c") do
        expect(salesforce_manuscript.Display_Technical_Notes__c).to be false
      end

      it("sets CreatedByDeltaMigration__c") do
        expect(salesforce_manuscript.CreatedByDeltaMigration__c).to be false
      end

      it("sets Editorial_Status_Date__c to the current time") do
        expect(salesforce_manuscript.Editorial_Status_Date__c.to_time.getutc).to be_the_same_time_as Time.now
      end

      it("sets Revision__c") do
        expect(salesforce_manuscript.Revision__c).to eq "0.0"
      end
    end
  end

end
