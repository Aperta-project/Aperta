require 'rails_helper'

describe DiscussionTopic::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:discussion_topic) { FactoryGirl.build(:discussion_topic) }

  it "serialize discussion_topic down the discussion_topic channel on creation" do
    expect(pusher_channel).to receive_push(payload: hash_including(:discussion_topic), down: 'discussion_topic', on: 'created')
    described_class.call("tahi:discussion_reply:created", { action: "created", record: discussion_topic })
  end

end
