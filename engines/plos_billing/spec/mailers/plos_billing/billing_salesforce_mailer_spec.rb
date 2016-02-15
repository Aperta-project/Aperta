require 'rails_helper'

describe PlosBilling::BillingSalesforceMailer do
  let(:doi) { "fake_doi" }
  let(:paper) { FactoryGirl.create(:paper, doi: doi, journal: journal) }
  let(:journal) { FactoryGirl.create(:journal) }
  let(:admin1) { FactoryGirl.create(:user) }
  let(:admin2) { FactoryGirl.create(:user) }

  describe "#notify_journal_admin_sfdc_error" do
    let(:message) { "Error! Bad things happened. Contact a Developer" }
    let(:email) do
      described_class.notify_journal_admin_sfdc_error(paper.id, message)
    end

    before do
      assign_journal_role journal, admin1, :admin
      assign_journal_role journal, admin2, :admin
    end

    it "displays the error message for developers" do
      expect(email.body).to include(message)
    end

    it "contains the paper doi" do
      expect(email.body).to include(doi)
    end

    it "is sent to the correct people" do
      expect(email.to).to contain_exactly(admin1.email, admin2.email)
    end
  end
end
