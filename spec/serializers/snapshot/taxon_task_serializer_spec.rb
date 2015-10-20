require "rails_helper"

describe Snapshot::TaxonTaskSerializer do
  let(:taxon_task) { FactoryGirl.create(:taxon_task)}

  it "serializes a taxon task" do
    snapshot = Snapshot::TaxonTaskSerializer.new(taxon_task).snapshot

    expect(snapshot[0][:name]).to eq("taxon_zoological")
    expect(snapshot[0][:children][0][:name]).to eq("complies")
    expect(snapshot[1][:name]).to eq("taxon_botanical")
    expect(snapshot[1][:children][0][:name]).to eq("complies")
  end
end
