require 'rails_helper'

describe Author::Updated::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:author) { FactoryGirl.build(:author) }

  it "serializes author down the paper channel on update" do
    expect(pusher_channel).to receive_push(serialize: :authors, down: 'paper', on: 'updated')
    described_class.call("tahi:author:updated", { action: "updated", record: author })
  end

end
