require 'rails_helper'

describe Task::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:task) { FactoryGirl.build(:task) }

  it "serializes supporting_information_file id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:task:destroyed", { action: "destroyed", record: task })
  end

end
