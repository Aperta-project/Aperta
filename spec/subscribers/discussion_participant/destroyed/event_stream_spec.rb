require 'rails_helper'

describe DiscussionParticipant::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:discussion_participant) { FactoryGirl.build(:discussion_participant) }

  it "serializes discussion_participant id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: :ids, down: 'system', on: 'destroyed')
    described_class.call("tahi:discussion_participant:destroyed", { action: "destroyed", record: discussion_participant })
  end

end
