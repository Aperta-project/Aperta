require 'rails_helper'

describe PaperRole::Destroyed::EventStream::NotifyAssignee do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:paper_role) { FactoryGirl.build(:paper_role, paper: paper) }

  it "serializes comment_look id down the system channel on destruction" do
<<<<<<< a7ea0f73b4f2c2f9542b7484f6fbf1777b4428fc
    expect(pusher_channel).to receive_push(payload: hash_including(:ids), down: 'system', on: 'destroyed')
    described_class.call("tahi:comment_look:destroyed", { action: "destroyed", record: comment_look })
=======
    expect(pusher_channel).to receive_push(serialize: paper, down: 'user', on: 'destroyed')
    described_class.call("tahi:paper_role:destroyed", { action: "destroyed", record: paper_role })
>>>>>>> APERTA-3272 APERTA-3204 APERTA-3270 Pusher pushes only ID and type.
  end

end
