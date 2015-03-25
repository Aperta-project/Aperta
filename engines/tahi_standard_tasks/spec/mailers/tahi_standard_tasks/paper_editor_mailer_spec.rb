require 'rails_helper'

describe TahiStandardTasks::PaperEditorMailer do

  let(:invitation) { FactoryGirl.create(:invitation) }

  let(:email) { described_class.notify_invited(invitation_id:invitation.id) }

  describe "#notify_invited" do
    it "sends email to the invitations email" do
      expect(email.to).to eq([invitation.email])
    end

    it "contains a link to the dashboard" do
      expect(email.body.raw_source).to match(%r{http://www.example.com/})
    end
  end
end
