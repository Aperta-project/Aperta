require 'rails_helper'

describe Comment::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:comment) { FactoryGirl.build(:comment) }

  it "serializes comment down the paper channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :comment, down: 'paper', on: 'created')
    described_class.call("tahi:comment:created", { action: "created", record: comment })
  end

end
