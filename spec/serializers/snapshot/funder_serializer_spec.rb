require "rails_helper"

describe Snapshot::FunderSerializer do
  subject(:serializer) { described_class.new(funder) }
  let(:funder) { FactoryGirl.create(:funder) }

  it "snapshots a funder" do
    expect(serializer.as_json).to include(
      name: "funder",
      type: "properties",
    )
  end

  it "snapshots a funder's properties" do
    expect(serializer.as_json[:children]).to include(
      {name: "name", type: "text", value: funder.name},
      {name: "grant_number", type: "text", value: funder.grant_number},
      {name: "website", type: "text", value: funder.website}
    )
  end

  it_behaves_like "snapshot serializes related nested questions", resource: :funder
end
