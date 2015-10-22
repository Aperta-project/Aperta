require 'rails_helper'

describe DiscussionReply::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:discussion_reply) { FactoryGirl.build(:discussion_reply) }

  it "serialize discussion_reply down the discussion_topic channel on update" do
    expect(pusher_channel).to receive_push(serialize: :discussion_reply, down: 'discussion_topic', on: 'updated')
    described_class.call("tahi:discussion_reply:updated", { action: "updated", record: discussion_reply })
  end

end
