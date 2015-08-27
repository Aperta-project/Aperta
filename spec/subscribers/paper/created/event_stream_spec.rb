require 'rails_helper'

describe Paper::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) { FactoryGirl.build(:paper, id: 44) } # PaperSerializer needs an id...

  it "serializes paper down the paper channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :paper, down: 'paper', on: 'created')
    described_class.call("tahi:paper:created", { action: "created", record: paper })
  end

end
