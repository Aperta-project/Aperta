require 'rails_helper'

describe Figure::Updated::EventStream do
  include EventStreamMatchers

  let(:pusher_channel) { mock_delayed_class(TahiPusher::Channel) }
  let!(:figure) { FactoryGirl.build(:figure) }

  it "serializes attachment down the paper channel on update" do
    expect(pusher_channel).to receive_push(serialize: :figure, down: 'paper', on: 'updated')
    described_class.call("tahi:figure:updated", { action: "updated", record: figure })
  end

end
