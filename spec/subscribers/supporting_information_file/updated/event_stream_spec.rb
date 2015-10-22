require 'rails_helper'

describe SupportingInformationFile::Updated::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:supporting_information_file) { FactoryGirl.build(:supporting_information_file) }

  it "serializes supporting_information_file down the paper channel on update" do
    expect(pusher_channel).to receive_push(serialize: :supporting_information_file, down: 'paper', on: 'updated')
    described_class.call("tahi:supporting_information_file:updated", { action: "updated", record: supporting_information_file })
  end

end
