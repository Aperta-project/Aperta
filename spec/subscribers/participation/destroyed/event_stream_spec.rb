require 'rails_helper'

describe Participation::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:participation) { FactoryGirl.build(:participation) }

  it "serializes comment id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:participation:destroyed", { action: "destroyed", record: participation })
  end

end
