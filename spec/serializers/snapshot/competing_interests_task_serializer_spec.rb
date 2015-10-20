require "rails_helper"

describe Snapshot::CompetingInterestsTaskSerializer do
  let(:competing_interest_task) { FactoryGirl.create(:competing_interests_task) }

  it "serializes a competing interest task" do
    snapshot = Snapshot::CompetingInterestsTaskSerializer.new(competing_interest_task).snapshot

    expect(snapshot[0][:name]).to eq("competing_interests")
    expect(snapshot[0][:children][0][:name]).to eq("statement")
  end
end
