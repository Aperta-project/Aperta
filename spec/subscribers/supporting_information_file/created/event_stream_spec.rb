require 'rails_helper'

describe SupportingInformationFile::Created::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:supporting_information_file) { FactoryGirl.build(:supporting_information_file) }

  it "serializes supporting_information_file down the paper channel on creation" do
    expect(pusher_channel).to receive_push(serialize: :supporting_information_file, down: 'paper', on: 'created')
    described_class.call("tahi:supporting_information:created", { action: "created", record: supporting_information_file })
  end

end
