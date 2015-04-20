require 'rails_helper'

describe Invitation do
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let(:invitation) { FactoryGirl.build :invitation, task: task }

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
      expect(task).to receive(:invitation_rescinded).with paper_id: invitation.paper.id, invitee_id: invitation.invitee.id
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
    it "sends an role invitation email" do
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
end
