require 'rails_helper'

describe Comment::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:comment) { FactoryGirl.build(:comment) }

  it "serializes comment id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:comment:destroyed", { action: "destroyed", record: comment })
  end

end
