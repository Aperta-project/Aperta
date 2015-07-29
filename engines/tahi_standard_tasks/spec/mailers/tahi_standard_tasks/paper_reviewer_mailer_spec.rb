require 'rails_helper'

shared_examples_for 'an invitation notification email' do |email_identifier_word:|
  let(:task) { create :paper_reviewer_task }
  let(:invitation) { create :invitation, task: task }

  it "implements an `email` object" do
    expect(self).to respond_to :email
  end

  it "sends an invitation email to the invitee" do
    expect(email.to.length).to eq 1
    expect(email.to.first).to eq invitation.invitee.email
  end

  specify { expect(email.body).to match(/#{task.paper.display_title}/) }
  specify { expect(email.body).to match(/#{invitation.invitee.full_name}/) }
  specify { expect(email.body).to match(/#{email_identifier_word}/) }
end

describe TahiStandardTasks::PaperReviewerMailer do
  describe ".notify_invited" do
    let(:email) { described_class.notify_invited invitation_id: invitation.id }
    it_behaves_like 'an invitation notification email', email_identifier_word: 'invited'
  end

  describe ".notify_rescission" do
    let(:email) { described_class.notify_rescission paper_id: invitation.paper.id, invitee_id: invitation.invitee.id }
    it_behaves_like 'an invitation notification email', email_identifier_word: 'rescinded'
  end
end
