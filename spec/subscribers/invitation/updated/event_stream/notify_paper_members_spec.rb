require 'rails_helper'

describe Invitation::Updated::EventStream::NotifyPaperMembers do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:invitation) { FactoryGirl.build(:invitation) }

  it "serializes invitation down the paper channel on update" do
    expect(pusher_channel).to receive_push(serialize: :invitation, down: 'paper', on: 'updated')
    described_class.call("tahi:invitation:updated", { action: "updated", record: invitation })
  end

end
