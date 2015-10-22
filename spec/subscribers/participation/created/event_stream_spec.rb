require 'rails_helper'

describe Participation::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:participation) { FactoryGirl.build(:participation) }

  it "serializes participation down the paper channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :participation, down: 'paper', on: 'created')
    described_class.call("tahi:participation:created", { action: "created", record: participation })
  end

end
