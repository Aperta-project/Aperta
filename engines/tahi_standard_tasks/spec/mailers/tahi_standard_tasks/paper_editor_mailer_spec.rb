require 'rails_helper'

describe TahiStandardTasks::PaperEditorMailer do

  let(:invitation) { FactoryGirl.create(:invitation, body: "Hiya, chief!") }

  let(:email) { described_class.notify_invited(invitation_id:invitation.id) }

  describe "#notify_invited" do
    it "has correct subject line" do
      expect(email.subject).to eq "You've been invited as an editor for the manuscript, \"#{invitation.task.paper.display_title}\""
    end

    it "has correct body content" do
      expect(email.body).to include invitation.body
    end

    it "sends email to the invitations email" do
      expect(email.to).to eq([invitation.email])
    end

    it "contains a link to the dashboard" do
      expect(email.body.raw_source).to match(%r{http://www.example.com/})
    end

    it "bcc's apertachasing@plos.org to support chasing in Salesforce" do
      expect(email.bcc).to include('apertachasing@plos.org')
    end
  end
end
