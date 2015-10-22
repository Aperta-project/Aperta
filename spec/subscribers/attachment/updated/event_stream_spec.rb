require 'rails_helper'

describe Attachment::Updated::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:attachment) { FactoryGirl.build(:attachment, :with_task) }

  it "serializes attachment down the paper channel on update" do
    expect(pusher_channel).to receive_push(serialize: :attachment, down: 'paper', on: 'updated')
    described_class.call("tahi:attachment:updated", { action: "updated", record: attachment })
  end

end
