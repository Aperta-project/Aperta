require 'rails_helper'

describe TahiStandardTasks::PaperAdminMailer do
  let(:user)        { FactoryGirl.create(:user) }
  let(:invitation)  { FactoryGirl.create(:invitation) }
  let!(:admin_role) { FactoryGirl.create(:paper_role, :admin, paper: invitation.paper, user: user) }
  let(:email) { described_class.notify_admin_of_editor_invite_accepted(paper_id: invitation.paper.id, editor_id: invitation.invitee.id) }

  describe "#notify_admin_of_editor_invite_accepted" do
    it "has correct subject line" do
      expect(email.subject).to eq "#{invitation.invitee.full_name} has accepted editor invitation on \"#{invitation.paper.journal.name}: #{invitation.paper.display_title}\""
    end

    it "has correct body content" do
      expect(email.body).to include "#{invitation.invitee.full_name} has accepted their editor invitation for \"#{invitation.paper.journal.name}: #{invitation.paper.display_title}\""
    end

    it "sends email to the admin of the paper" do
      expect(email.to).to eq([invitation.paper.admin.email])
    end

    it "contains a link to the paper" do
      expect(email.body.raw_source).to match(%r{http://www.example.com/papers/#{invitation.paper.id}})
    end

    context "without a paper.admin" do
      before do
        admin_role.destroy
      end

      it "does not email the admin" do
        expect(email.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end
end
