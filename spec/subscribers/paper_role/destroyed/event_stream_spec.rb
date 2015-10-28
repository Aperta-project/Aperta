require 'rails_helper'

describe PaperRole::Destroyed::EventStream::NotifyAssignee do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:paper_role) { FactoryGirl.build(:paper_role, paper: paper) }

  it "serializes comment_look id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: paper, down: 'user', on: 'destroyed')
    described_class.call("tahi:paper_role:destroyed", { action: "destroyed", record: paper_role })
  end

end
