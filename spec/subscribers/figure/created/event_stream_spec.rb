require 'rails_helper'

describe Figure::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:figure) { FactoryGirl.build(:figure) }

  it "serializes attachment down the paper channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :figure, down: 'paper', on: 'created')
    described_class.call("tahi:figure:created", { action: "created", record: figure })
  end

end
