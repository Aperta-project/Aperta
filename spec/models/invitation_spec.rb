require 'rails_helper'

describe Invitation do
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let(:invitation) { FactoryGirl.build :invitation, task: task }

  describe ".invited" do
    let!(:open_invitation_1) { FactoryGirl.create(:invitation, :invited) }
    let!(:open_invitation_2) { FactoryGirl.create(:invitation, :invited) }
    let!(:accepted_invitation) { FactoryGirl.create(:invitation, state: 'accepted') }

    it "returns invitations that are in the 'invited' state" do
      expect(Invitation.invited).to include(open_invitation_1, open_invitation_2)
    end

    it "does not include invitations that are not in the 'invited' state" do
      expect(Invitation.invited).to_not include(accepted_invitation)
    end
  end

  describe '#create' do
    it "belongs to the paper's latest decision" do
      invitation.save!
      expect(phase.paper.decisions.latest.invitations).to include invitation
    end

    context 'when there is more than one decision' do
      it 'is associated with the latest decision' do
        latest_decision = FactoryGirl.create :decision, paper: phase.paper
        invitation.save!
        latest_revision_number = (phase.paper.decisions.pluck :revision_number).max
        expect(invitation.decision).to eq latest_decision
        expect(invitation.decision).to eq phase.paper.decisions.latest
        expect(invitation.decision.revision_number).to eq latest_revision_number
      end
    end

  end

  describe '#destroy' do
    it "calls #after_destroy hook" do
      expect(task).to receive(:invitation_rescinded).with invitation
      invitation.destroy!
    end
  end

  describe "#invite!" do
    it "is invited by default" do
      expect(task).to receive(:invite_allowed?).with(invitation).and_return(true)
      expect(task).to receive(:invitation_invited).with(invitation)
      invitation.invite!
      # DatabaseCleaner transaction strategy won't commit. Do it manually :(
      invitation.run_callbacks(:commit)
    end

    it "prevents transition to invited" do
      allow(invitation).to receive(:invite_allowed?).and_return(false)
      expect { invitation.invite! }.to raise_exception(AASM::InvalidTransition)
      expect(invitation.invited?).to be_falsey
    end
  end

  describe "#accept!" do
    it "sends an old_role invitation email" do
      invitation.invite!
      expect(task).to receive(:accept_allowed?).with(invitation).and_return(true)
      expect(task).to receive(:invitation_accepted).with(invitation)
      invitation.accept!
    end

    it "prevents transition to accepted" do
      invitation.invite!
      expect(task).to receive(:accept_allowed?) .with(invitation).and_return(false)
      expect { invitation.accept! }.to raise_exception(AASM::InvalidTransition)
      invitation.run_callbacks(:commit)
      expect(invitation.invited?).to be_truthy
      expect(invitation.accepted?).to be_falsey
    end
  end

  describe "#reject!" do
    it "calls the the invitation rejection callback" do
      invitation.invite!
      expect(task).to receive(:reject_allowed?).with(invitation).and_return(true)
      expect(task).to receive(:invitation_rejected).with(invitation)
      invitation.reject!
    end

    it "prevents transition to rejected" do
      invitation.invite!
      expect(task).to receive(:reject_allowed?) .with(invitation).and_return(false)
      expect { invitation.reject! }.to raise_exception(AASM::InvalidTransition)
      invitation.run_callbacks(:commit)
      expect(invitation.invited?).to be_truthy
      expect(invitation.rejected?).to be_falsey
    end
  end

  describe "#recipient_name" do
    let(:invitee) { FactoryGirl.build(:user, first_name: "Ben", last_name: "Howard")}

    before do
      invitation.invitee = invitee
      invitation.email = "ben.howard@example.com"
    end

    context "and there is an invitee" do
      it "returns the's invitee's full_name" do
        expect(invitation.recipient_name).to eq("Ben Howard")
      end
    end

    context "and there is no invitee" do
      it "returns the email that the invitation is for" do
        invitation.invitee = nil
        expect(invitation.recipient_name).to eq("ben.howard@example.com")
      end
    end
  end
end
