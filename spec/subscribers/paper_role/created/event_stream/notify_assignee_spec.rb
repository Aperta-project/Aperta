require 'rails_helper'

describe PaperRole::Created::EventStream::NotifyAssignee do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:paper) { FactoryGirl.create(:paper) }
  let!(:paper_role) { FactoryGirl.build(:paper_role, paper: paper) }

  it "serializes paper down the user channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :paper, down: 'user', on: 'created')
    described_class.call("tahi:paper_role:created", { action: "created", record: paper_role })
  end

end
