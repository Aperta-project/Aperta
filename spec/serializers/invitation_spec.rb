require "rails_helper"

describe InvitationSerializer do
  let(:user) { FactoryGirl.create :user }
  let(:phase) { FactoryGirl.create :phase }
  let(:task) { FactoryGirl.create :invitable_task, phase: phase }
  let(:invitation) { FactoryGirl.create :invitation, task: task, invitee: user }

  it "serializes successfully" do
    hash = JSON.parse InvitationSerializer.new(invitation).to_json, symbolize_names: true
    expect(hash[:invitation].class).to be Hash
  end

  context "without an invitee" do
    before do
      invitation.invitee = nil
    end

    it "serializes successfully" do
      hash = JSON.parse InvitationSerializer.new(invitation).to_json, symbolize_names: true
      expect(hash[:invitation].class).to be Hash
    end
  end
end
