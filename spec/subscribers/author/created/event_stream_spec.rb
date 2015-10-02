require 'rails_helper'

describe Author::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:author) { FactoryGirl.build(:author) }

  it "serializes author down the paper channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :authors, down: 'paper', on: 'created')
    described_class.call("tahi:author:created", { action: "created", record: author })
  end

end
