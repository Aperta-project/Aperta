require 'rails_helper'

describe Figure::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:figure) { FactoryGirl.build(:figure) }

  it "serializes attachment id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:figure:destroyed", { action: "destroyed", record: figure })
  end

end
