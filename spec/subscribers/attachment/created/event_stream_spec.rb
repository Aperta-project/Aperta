require 'rails_helper'

describe Attachment::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:attachment) { FactoryGirl.build(:attachment, :with_task) }

  it "serializes attachment down the paper channel on creation" do
    expect(pusher_channel).to receive_push(payload: hash_including(:attachment), down: 'paper', on: 'created')
    described_class.call("tahi:attachment:created", { action: "created", record: attachment })
  end

end
