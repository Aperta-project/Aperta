require 'rails_helper'

describe CommentLook::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:comment_look) { FactoryGirl.build(:comment_look) }

  it "serializes author down the paper channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :comment_look, down: 'user', on: 'created')
    described_class.call("tahi:comment_look:created", { action: "created", record: comment_look })
  end

end
