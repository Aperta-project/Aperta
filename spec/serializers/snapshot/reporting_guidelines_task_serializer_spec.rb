require "rails_helper"

describe Snapshot::ReportingGuidelinesTaskSerializer do
  let(:reporting_guidelines_task) {FactoryGirl.create(:reporting_guidelines_task)}

  it "serializes a reporting guidelines task" do
    snapshot = Snapshot::ReportingGuidelinesTaskSerializer.new(reporting_guidelines_task).snapshot

    expect(snapshot[0][:name]).to eq("clinical_trial")
    expect(snapshot[1][:name]).to eq("systematic_reviews")
    expect(snapshot[1][:children][0][:name]).to eq("checklist")
    expect(snapshot[2][:name]).to eq("meta_analyses")
    expect(snapshot[2][:children][0][:name]).to eq("checklist")
    expect(snapshot[3][:name]).to eq("diagnostic_studies")
    expect(snapshot[4][:name]).to eq("epidemiological_studies")
    expect(snapshot[5][:name]).to eq("microarray_studies")
  end
end
