require 'rails_helper'

describe DiscussionTopic::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:discussion_topic) { FactoryGirl.build(:discussion_topic) }

  it "serializes discussion_topic id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:discussion_topic:destroyed", { action: "destroyed", record: discussion_topic })
  end

end
