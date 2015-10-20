require 'rails_helper'

describe Paper::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) { FactoryGirl.build(:paper) }

  it "serializes paper id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(payload: hash_including(:ids), down: 'system', on: 'destroyed')
    described_class.call("tahi:paper:destroyed", { action: "destroyed", record: paper })
  end

end
