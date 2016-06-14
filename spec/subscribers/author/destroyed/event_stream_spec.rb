require 'rails_helper'

describe Author::Destroyed::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:author) { FactoryGirl.create(:author, paper: paper) }

  it "serializes author id down the system channel on destruction" do
    expect(pusher_channel).to receive_push(serialize: author, down: 'system', on: 'destroyed')
    described_class.call("tahi:author:destroyed", { action: "destroyed", record: author })
  end

end
