require "rails_helper"

describe Snapshot::FinancialDisclosureTaskSerializer do
  let(:task) {FactoryGirl.create(:financial_disclosure_task)}

  it "serializes a financial disclosure task" do
    snapshot = Snapshot::FinancialDisclosureTaskSerializer.new(task).snapshot

    expect(snapshot[0][:name]).to eq("author_received_funding")
  end

  it "serializes with funders" do
    funder1 = FactoryGirl.create(:funder)
    funder2 = FactoryGirl.create(:funder)
    task.funders << funder1
    task.funders << funder2

    snapshot = Snapshot::FinancialDisclosureTaskSerializer.new(task).snapshot

    expect(snapshot[0][:name]).to eq("author_received_funding")
    expect(snapshot[1][:name]).to eq("funder")
    expect(snapshot[1][:children][0][:value]).to eq(funder1[:name])
    expect(snapshot[1][:children][3][:name]).to eq("funder_had_influence")
    expect(snapshot[1][:children][3][:children][0][:name]).to eq("funder_role_description")
    expect(snapshot[1][:children][1][:value]).to eq(funder1[:grant_number])
    expect(snapshot[2][:children][1][:value]).to eq(funder2[:grant_number])
  end
end
