require 'rails_helper'

describe PaperRole::Created::EventStream::NotifyEveryone do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:paper_role) { FactoryGirl.build(:paper_role, paper: paper) }

  it "serializes paper down the user channel on creation" do
    expect(pusher_channel).to receive_push(serialize: paper, down: 'paper', on: 'updated')
    described_class.call("tahi:paper_role:created", { action: "created", record: paper_role })
  end

end
