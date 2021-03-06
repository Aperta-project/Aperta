# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe SalesforceServices::API do
  let(:paper) { FactoryGirl.create(:paper, :with_co_authors) }

  around do |example|
    ClimateControl.modify SALESFORCE_ENABLED: 'true', SALESFORCE_HOST: 'salesforce.local' do
      example.run
    end
  end

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

  describe "#create_manuscript" do
    it "calls create on a Salesforce Manuscript__c object" do
      mock_manuscript = instance_double("Manuscript__c", Id: 'sfdc')
      expect(Manuscript__c).to receive(:create).and_return(mock_manuscript)
      manuscript = @api.create_manuscript(paper: paper)
      expect(manuscript).to eq mock_manuscript
    end
  end

  describe "#update_manuscript" do
    let(:paper) do
      FactoryGirl.create(:paper, :with_co_authors, salesforce_manuscript_id: "sfdc_id_1")
    end
    it "finds then updates a Salesforce Manuscript__c object" do
      mock_manuscript = instance_double("Manuscript__c", Id: 'sfdc')
      expect(Manuscript__c).to receive(:find)
        .with(paper.salesforce_manuscript_id)
        .and_return(mock_manuscript)
      expect(mock_manuscript).to receive(:update_attributes)
      manuscript = @api.update_manuscript(paper: paper)
      expect(manuscript).to eq mock_manuscript
    end
  end

  describe "#find_or_create_manuscript" do
    it "calls create when salesforce_manuscript_id is not present" do
      expect(paper.salesforce_manuscript_id).to be_nil
      expect(SalesforceServices::API).to receive(:create_manuscript).and_return(true)
      SalesforceServices::API.find_or_create_manuscript(paper: paper)
    end

    it "calls update when salesforce_manuscript_id is present" do
      paper.update_attribute(:salesforce_manuscript_id, "foo")
      expect(paper.salesforce_manuscript_id).to be_truthy
      expect(SalesforceServices::API).to receive(:update_manuscript).and_return(true)
      SalesforceServices::API.find_or_create_manuscript(paper: paper)
    end
  end

  describe '#ensure_pfa_case' do
    let(:journal) { FactoryGirl.create(:journal) }
    let(:paper) do |paper|
      task_params = {
        title: 'Billing',
        type: 'PlosBilling::BillingTask',
        paper_id: paper.id
      }
      FactoryGirl.create(:paper_with_task,
        task_params: task_params,
        journal: journal)
    end

    before do
      allow(Paper).to receive(:find).with(paper.id).and_return(paper)
      allow(paper).to receive(:creator) { FactoryGirl.build(:user) }
      FactoryGirl.create(:financial_disclosure_task, paper: paper)
      expect(Case).to receive(:soql_conditions_for)
        .with("Subject" => paper.manuscript_id.to_s)
    end

    context "existing PFA case on salesforce" do
      before do
        expect(Case.client).to receive(:query) { [true] }
      end

      it "doesn't create a new case" do
        expect(Case).to_not receive(:create)
        @api.ensure_pfa_case(paper: paper)
      end
    end

    context "new PFA case" do
      before do
        expect(Case.client).to receive(:query) { nil }
      end

      it 'creates and returns a salesforce case object' do
        VCR.use_cassette("salesforce_instantiate_client") do
          @api = SalesforceServices::API
          @api.client
        end

        VCR.use_cassette("salesforce_create_billing_and_pfa") do
          @kase = @api.ensure_pfa_case(paper: paper)
          expect(@kase.class).to eq Case
          expect(@kase.persisted?).to eq true
        end
      end
    end
  end
end

def delete_vcr_file(file) # useful when writing new specs that require vcr, and need the http request need to be made multiple times until correct
  file = "spec/fixtures/vcr_cassettes/#{file}.yml"
  ap "deleting #{file}" if File.exist?(file) && File.delete(file)
end
