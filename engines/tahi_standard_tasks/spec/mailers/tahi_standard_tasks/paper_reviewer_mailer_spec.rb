require 'rails_helper'
include ClientRouteHelper

shared_examples_for 'an invitation notification email' do |email_identifier_word:|
  it "implements an `email` object" do
    expect(self).to respond_to :email
  end

  it "sends an invitation email to the invitee" do
    expect(email.to.length).to eq 1
    expect(email.to.first).to eq invitation.email
  end

  specify { expect(email.body).to match(/#{task.paper.display_title(sanitized: false)}/) }
  specify { expect(email.body).to match(/#{email_identifier_word}/) }
end

describe TahiStandardTasks::PaperReviewerMailer do
  let(:task) { create(:paper_reviewer_task) }
  let(:invitation) do
    create(
      :invitation,
      body: "Dear SoAndSo, You've been invited to be a reviewer on a manuscript",
      task: task
    )
  end

  describe ".notify_invited" do
    let(:email) { described_class.notify_invited invitation_id: invitation.id }
    it_behaves_like 'an invitation notification email', email_identifier_word: 'invited'

    describe "email content and formatting" do
      it "has correct subject line" do
        expect(email.subject).to eq "You have been invited as a reviewer for the manuscript, \"#{task.paper.display_title}\""
      end

      it "includes the invitation body as part of the email" do
        expect(email.body).to include invitation.body
      end

      it "has a dashboard link" do
        expect(email.body).to include client_dashboard_url
      end
    end

    describe "email body content" do
      it "includes appropriate body text" do
        expect(email.body).to include "You've been invited to"
      end
    end
  end

  describe ".notify_rescission" do
    let(:invitation) { create :invitation, task: task, email: "foo@bar.com" }

    let(:email) do
      described_class.notify_rescission(
        recipient_email: invitation.email,
        recipient_name: invitation.invitee.full_name,
        paper_id: invitation.paper.id
      )
    end

    it_behaves_like 'an invitation notification email', email_identifier_word: 'rescinded'

    describe "email content and formatting" do
      it "has correct subject line" do
        expect(email.subject).to eq "Your invitation to be a reviewer has been rescinded for the manuscript, \"#{task.paper.display_title}\""
      end
    end

    describe "email body content" do
      it "includes appropriate body text" do
        expect(email.body).to include "Invitation Rescinded"
      end
    end
  end
end
