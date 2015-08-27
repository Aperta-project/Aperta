require 'rails_helper'

describe Invitation::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:invitation) { FactoryGirl.build(:invitation) }

  it "serializes invitation id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:invitation:destroyed", { action: "destroyed", record: invitation })
  end

end
