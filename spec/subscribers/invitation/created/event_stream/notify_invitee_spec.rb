require 'rails_helper'

describe Invitation::Created::EventStream::NotifyInvitee do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:invitation) { FactoryGirl.build(:invitation) }

  it "serializes invitation down the user channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :invitation, down: 'user', on: 'created')
    described_class.call("tahi:invitation:created", { action: "created", record: invitation })
  end

end
