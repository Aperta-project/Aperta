require 'rails_helper'

describe PlosBilling::BillingSalesforceMailer do
  let(:paper) { FactoryGirl.create(:paper) }
  let(:site_admin_role) { FactoryGirl.create(:role, :site_admin) }
  let(:the_system) { System.create! }
  let!(:admin1) { FactoryGirl.create(:user) }
  let!(:admin2) { FactoryGirl.create(:user) }

  describe "#notify_site_admins_of_syncing_error" do
    let(:message) { "Error! Bad things happened. Contact a Developer" }
    let(:email) do
      described_class.notify_site_admins_of_syncing_error(paper.id, message)
    end

    before do
      admin1.assign_to! assigned_to: the_system, role: site_admin_role
      admin2.assign_to! assigned_to: the_system, role: site_admin_role
    end

    it "displays the error message for developers" do
      expect(email.body).to include(message)
    end

    it "contains the paper doi" do
      expect(email.body).to include(paper.doi)
    end

    it "is sent to the users assigned as site admins" do
      expect(email.to).to contain_exactly(admin1.email, admin2.email)
    end
  end
end
