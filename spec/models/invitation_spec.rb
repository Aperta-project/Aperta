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

  def invitation_rejected(_invitation)
    "rejected"
  end
end

describe Invitation do
  let(:phase) { FactoryGirl.create(:phase) }
  let(:task) { phase.tasks.create(type: "TestTask", title: "Test", role: "user") }
  let(:invitation) { FactoryGirl.build(:invitation, task: task) }

  describe "#invite!" do
    it "is invited by default" do
      expect(task).to receive(:invitation_invited).with(invitation)
      invitation.invite!
      # DatabaseCleaner transaction strategy won't commit. Do it manually :(
      invitation.run_callbacks(:commit)
    end
  end

  describe "#accept!" do
    it "sends an role invitation email" do
      invitation.invite!
      expect(task).to receive(:invitation_accepted).with(invitation)
      invitation.accept!
    end
  end

  describe "#reject!" do
    it "calls the the invitation rejection callback" do
      invitation.invite!
      expect(task).to receive(:invitation_rejected).with(invitation)
      invitation.reject!
    end
  end
end
