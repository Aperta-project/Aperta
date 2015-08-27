require 'rails_helper'

describe Attachment::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:attachment) { FactoryGirl.build(:attachment, :with_task) }

  it "serializes attachment id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:attachment:destroyed", { action: "destroyed", record: attachment })
  end

end
