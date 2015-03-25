require 'rails_helper'

class TestTask < Task
  include TaskTypeRegistration
  include Invitable

  register_task default_title: "Test Task", default_role: "user"

  def invitation_invited(_invitation)
    "invited"
  end

  def invitation_accepted(_invitation)
    "accepted"
  end
end

describe Invitation do
  let(:phase) { FactoryGirl.create(:phase) }
  let(:task) { phase.tasks.create(type: "TestTask", title: "Test", role: "user") }
  let(:invitation) { FactoryGirl.build(:invitation, task: task) }

  context  "state machine events" do

    describe "#invite!" do
      it "tarnsitions from pending to invite" do
        invitation.invite!
        expect(invitation.invited?).to be_truthy
      end

      it "triggers an invitation call back in the associated task" do
        expect(task).to receive(:invitation_invited).with(invitation)
        invitation.invite!
      end

      it "generates a code for the invitation" do
        invitation.invite!
        expect(invitation.code).not_to be_nil
      end

      it "associates an existing user to the invitation" do
        user = FactoryGirl.create(:user, email: "user@example.com")
        invitation.email = "user@example.com"
        expect(invitation.invitee).to be_nil
        invitation.invite!
        expect(invitation.invitee).to eql(user)
      end
    end

    describe "#accept!" do
      it "sends an role invitation email" do
        invitation.invite!
        expect(task).to receive(:invitation_accepted).with(invitation)
        invitation.accept!
      end

      it "changes to accepted" do
        invitation.invite!
        invitation.accept!
        expect(invitation.accepted?).to be_truthy
      end

      it "nakes transition from closed to willing" do
        invitation2 = FactoryGirl.create(:invitation, task: task)
        invitation.invite!
        invitation2.invite!
        invitation.accept!
        invitation2.close!
        allow(invitation2).to receive(:accept_allowed?).and_return(false)
        invitation2.accept!
        expect(invitation.accepted?).to be_truthy
        expect(invitation2.willing?).to be_truthy
      end
    end

    describe "#reject!" do
      it "makes a transition from invited to rejected" do
        invitation.invite!
        invitation.reject!
        expect(invitation.rejected?).to be_truthy
      end

      it "makes a transition from closed to rejected" do
        invitation.invite!
        invitation.close!
        invitation.reject!
        expect(invitation.rejected?).to be_truthy
      end
    end

    describe "#close!" do
      it "makes a transition from invited to closed" do
        invitation.invite!
        invitation.close!
        expect(invitation.closed?).to be_truthy
      end
    end
  end

end
