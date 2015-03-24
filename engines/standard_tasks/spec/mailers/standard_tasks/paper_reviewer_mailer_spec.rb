require 'rails_helper'

describe StandardTasks::PaperReviewerMailer do
  let(:task) { create :paper_reviewer_task }
  let(:invitation) { create :invitation, task: task }

  describe ".notify_invited" do
    let(:email) { described_class.notify_invited invitation_id: invitation.id }

    it "sends an invitation email to the invitee" do
      expect(email.to.length).to eq 1
      expect(email.to.first).to eq invitation.invitee.email
    end
 
    it "contains the paper display title" do
      expect(email.body).to match(/#{task.paper.title}/)
    end

    it "greets the invitee by name" do
      expect(email.body).to match(/#{invitation.invitee.full_name}/)
    end
  end

  describe ".notify_rejection" do
    let(:email) { described_class.notify_rejection invitation_id: invitation.id }
    it "sends a rejection email to the invitee" do
      expect(email.to.length).to eq 1
      expect(email.to.first).to eq invitation.invitee.email
    end

    it "contains the paper display title" do
      expect(email.body).to match(/#{task.paper.display_title}/)
    end

    it "greets the invitee by name" do
      expect(email.body).to match(/#{invitation.invitee.full_name}/)
    end

    it "mentions that the invitation has been recinded" do
      expect(email.body).to match(/recinded/)
    end
  end
end
