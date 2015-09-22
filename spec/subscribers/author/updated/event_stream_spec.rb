require 'rails_helper'

describe Author::Updated::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:author) { FactoryGirl.create(:author, paper: paper) }


  it "serializes author down the paper channel on update" do
    expect(pusher_channel).to receive_push(serialize: author, down: 'paper', on: 'updated')
    described_class.call("tahi:author:updated", { action: "updated", record: author })
  end

end
