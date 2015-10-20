require 'rails_helper'

describe Invitation::Created::EventStream::NotifyPaperMembers do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:invitation) { FactoryGirl.build(:invitation) }

  it "serializes invitation down the paper channel on creation" do
    expect(pusher_channel).to receive_push(payload: hash_including(:invitation), down: 'paper', on: 'created')
    described_class.call("tahi:invitation:created", { action: "created", record: invitation })
  end

end
