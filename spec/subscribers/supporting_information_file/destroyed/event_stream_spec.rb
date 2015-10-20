require 'rails_helper'

describe SupportingInformationFile::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:supporting_information_file) { FactoryGirl.build(:supporting_information_file) }

  it "serializes supporting_information_file id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(payload: hash_including(:ids), down: 'system', on: 'destroyed')
    described_class.call("tahi:supporting_information_file:destroyed", { action: "destroyed", record: supporting_information_file })
  end

end
