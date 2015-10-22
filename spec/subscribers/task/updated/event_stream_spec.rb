require 'rails_helper'

describe Task::Updated::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:task) { FactoryGirl.build(:task) }

  it "serializes supporting_information_file down the paper channel on update" do
    expect(pusher_channel).to receive_push(serialize: :task, down: 'paper', on: 'updated')
    described_class.call("tahi:task:updated", { action: "updated", record: task })
  end

end
