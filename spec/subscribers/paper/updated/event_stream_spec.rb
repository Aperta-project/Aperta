require 'rails_helper'

describe Paper::Updated::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) { FactoryGirl.create(:paper) }

  it "serializes paper down the paper channel on update" do
    expect(pusher_channel).to receive_push(serialize: :paper, down: 'paper', on: 'updated')
    described_class.call("tahi:paper:updated", { action: "updated", record: paper })
  end

end
