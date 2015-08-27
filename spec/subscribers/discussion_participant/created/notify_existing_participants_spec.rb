require 'rails_helper'

describe DiscussionParticipant::Created::NotifyExistingParticipants do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:discussion_participant) { FactoryGirl.build(:discussion_participant) }

  it "serializes discussion participtant down the discussion topic channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :discussion_participant, down: 'discussion_topic', on: 'created')
    described_class.call("tahi:discussion_participtant:created", { action: "created", record: discussion_participant })
  end

end
