require 'rails_helper'

describe ReviewerReport do
  subject(:paper) { FactoryGirl.create(:paper, :submitted_lite) }
  subject(:task) { FactoryGirl.create(:reviewer_report_task, paper: paper) }
  subject(:reviewer_report) { FactoryGirl.create(:reviewer_report, task: task) }

  def add_invitation(state)
    invitation = FactoryGirl.create(:invitation,
      invitee: subject.user,
      invited_at: DateTime.now.utc,
      declined_at: DateTime.now.utc + 10,
      rescinded_at: DateTime.now.utc + 20,
      accepted_at: DateTime.now.utc + 30,
      state: state)
    subject.decision.invitations << invitation
  end

  describe "report states" do
    it "defaults to :invitation_not_accepted" do
      expect(subject.invitation_not_accepted?).to be true
    end

    it "can move from :invitation_not_accepted to :review_pending" do
      add_invitation(:accepted)
      subject.accept_invitation
      expect(subject.review_pending?).to be true
    end

    it "can move from :review_pending to :submitted" do
      add_invitation(:accepted)
      subject.accept_invitation
      subject.submit
      expect(subject.submitted?).to be true
    end

    it "can move from :review_pending to :invitation_not_accepted" do
      add_invitation(:accepted)
      subject.accept_invitation
      subject.rescind_invitation
      expect(subject.invitation_not_accepted?).to be true
    end

    it "can move from :invitation_not_accepted to :invitation_not_accepted" do
      expect(subject.invitation_not_accepted?).to be true
      subject.rescind_invitation
      expect(subject.invitation_not_accepted?).to be true
    end

    it "can not move from :submitted" do
      add_invitation(:accepted)
      subject.accept_invitation
      subject.submit
      expect { subject.rescind_invitation }.to raise_error(AASM::InvalidTransition)
    end
  end

  describe "#invitation_accepted?" do
    it "is true for an accepted invitation" do
      add_invitation(:accepted)
      expect(subject.invitation_accepted?).to be true
    end

    it "is false for an unaccpeted invitation" do
      add_invitation(:rescinded)
      expect(subject.invitation_accepted?).to be false
    end
  end

  describe "#computed_status" do
    it "has status 'not_invited' without an invitation" do
      expect(subject.computed_datetime).to be_nil
      expect(subject.computed_status).to eq("not_invited")
    end

    it "has status 'invitation_invited' if invited" do
      add_invitation(:invited)
      expect(subject.computed_datetime).to eq(subject.invitation.invited_at)
      expect(subject.computed_status).to eq("invitation_invited")
    end

    it "has status 'invitation_declined' if declined" do
      add_invitation(:declined)
      expect(subject.computed_datetime).to eq(subject.invitation.declined_at)
      expect(subject.computed_status).to eq("invitation_declined")
    end

    it "has status 'invitation_rescinded' if rescinded" do
      add_invitation(:rescinded)
      expect(subject.computed_datetime).to eq(subject.invitation.rescinded_at)
      expect(subject.computed_status).to eq("invitation_rescinded")
    end

    it "has status 'pending' if invite accepted" do
      add_invitation(:accepted)
      subject.accept_invitation

      expect(subject.computed_datetime).to eq(subject.invitation.accepted_at)
      expect(subject.computed_status).to eq("pending")
    end

    it "has status 'complete' if invite accepted and report submitted" do
      add_invitation(:accepted)
      subject.accept_invitation
      subject.submit

      expect(subject.computed_status).to eq("completed")
    end
  end

  describe "#revision" do
    it "defaults to v0.0" do
      subject.task.paper.versioned_texts = []
      subject.decision.major_version = nil
      subject.decision.minor_version = nil

      expect(subject.revision).to eq('v0.0')
    end

    it "falls back to paper's version" do
      paper = subject.task.paper
      paper_revision = "v#{paper.major_version}.#{paper.minor_version}"
      subject.decision.major_version = nil
      subject.decision.minor_version = nil

      expect(subject.revision).to eq(paper_revision)
    end

    it "uses decision's versions" do
      subject.decision.major_version = 1
      subject.decision.minor_version = 2

      expect(subject.revision).to eq('v1.2')
    end

    it "prefers decision's versions" do
      subject.decision.major_version = 1
      subject.decision.minor_version = 2

      expect(subject.revision).to eq('v1.2')
    end
  end
end
