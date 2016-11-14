require 'rails_helper'

describe TahiStandardTasks::PaperAdminMailer do
  let(:user)        { FactoryGirl.create(:user) }
  let(:journal)     { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:admin)       { FactoryGirl.create(:user) }
  let(:paper)       { FactoryGirl.create(:paper, journal: journal) }
  let(:invitation)  { FactoryGirl.create(:invitation, paper: paper) }
  let(:email) { described_class.notify_admin_of_editor_invite_accepted(paper_id: invitation.paper.id, editor_id: invitation.invitee.id) }

  describe "#notify_admin_of_editor_invite_accepted" do
    context "with a paper.journal.staff_admin" do
      before do
        admin.assign_to!(role: journal.staff_admin_role, assigned_to: journal)
      end
      it "has correct subject line" do
        expect(email.subject).to eq "#{invitation.invitee.full_name} has accepted editor invitation on \"#{invitation.paper.journal.name}: #{invitation.paper.display_title}\""
      end

      it "has correct body content" do
        expect(email.body).to include "#{invitation.invitee.full_name} has accepted their editor invitation for \"#{invitation.paper.journal.name}: #{invitation.paper.display_title(sanitized: false)}\""
      end

      it "sends email to the admin of the paper" do
        expect(email.to).to eq([admin.email])
      end

      it "contains a link to the paper" do
        expect(email.body.raw_source).to match(%r{http://www.example.com/papers/#{invitation.paper.id}})
      end
    end

    context "without a paper.journal.staff_admin" do
      it "does not email the admin" do
        expect(email.message).to be_a(ActionMailer::Base::NullMail)
      end
    end
  end
end
