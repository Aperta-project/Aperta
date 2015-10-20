require 'rails_helper'

describe Task::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:task) { FactoryGirl.build(:task) }

  it "serializes supporting_information_file down the paper channel on creation" do
    expect(pusher_channel).to receive_push(payload: hash_including(:task), down: 'paper', on: 'created')
    described_class.call("tahi:task:created", { action: "created", record: task })
  end

end
