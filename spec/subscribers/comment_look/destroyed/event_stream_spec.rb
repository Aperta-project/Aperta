require 'rails_helper'

describe CommentLook::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:comment_look) { FactoryGirl.build(:comment_look) }

  it "serializes comment_look id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:comment_look:destroyed", { action: "destroyed", record: comment_look })
  end

end
