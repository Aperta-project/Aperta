require 'rails_helper'

describe Invitation::Updated::EventStream::NotifyInvitee do
  include EventStreamMatchers

  context "with an invitee" do
    let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
    let(:invitation) { FactoryGirl.build(:invitation) }

    it "serializes invitation down the user channel on update" do
      expect(pusher_channel).to receive_push(serialize: invitation, down: 'user', on: 'updated')
      described_class.call("tahi:invitation:updated", { action: "updated", record: invitation })
    end
  end

  context "without an invitee (invitee is user without an tahi account)" do
    let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
    let(:invitation) { FactoryGirl.build(:invitation, invitee: nil) }

    it "does not serialize invitation" do
      expect(pusher_channel).to_not receive(:push)
      described_class.call("tahi:invitation:updated", { action: "updated", record: invitation })
    end
  end
end
