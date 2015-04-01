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

describe StandardTasks::PaperReviewerMailer do
  describe ".notify_invited" do
    let(:email) { described_class.notify_invited invitation_id: invitation.id }
    it_behaves_like 'an invitation notification email', email_identifier_word: 'assigned'
  end

  describe ".notify_rejection" do
    let(:email) { described_class.notify_rejection invitation_id: invitation.id }
    it_behaves_like 'an invitation notification email', email_identifier_word: 'rescinded'
  end
end
