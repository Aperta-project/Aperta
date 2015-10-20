require 'rails_helper'

describe DiscussionReply::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:discussion_reply) { FactoryGirl.build(:discussion_reply) }

  it "serializes discussion_reply id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(payload: hash_including(:ids), down: 'system', on: 'destroyed')
    described_class.call("tahi:discussion_reply:destroyed", { action: "destroyed", record: discussion_reply })
  end

end
