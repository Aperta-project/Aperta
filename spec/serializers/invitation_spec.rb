require "rails_helper"

describe InvitationSerializer, serializer_test: true do
  let(:user) { FactoryGirl.create :user }
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  subject(:invitation) { FactoryGirl.create :invitation, task: task, invitee: user }

  it "serializes successfully" do
    expect(deserialized_content).to match(hash_including(:invitation))
  end

  context "without an invitee" do
    subject(:invitation) { FactoryGirl.create :invitation, task: task, invitee: nil }

    it "serializes successfully" do
      expect(deserialized_content).to match(hash_including(:invitation, users: []))
    end
  end
end
