require 'rails_helper'

describe Decision do
  let(:paper) { FactoryGirl.create :paper }
  let!(:decision) { paper.decisions.first }

  it "the first decision always has 0 revision number" do
    expect(decision.revision_number).to eq(0)
  end

  it "automatically increments the revision number" do
    new_decision = paper.decisions.create!
    expect(new_decision.revision_number).to eq 1
  end

  it "automatically increments the revision number" do
    new_decision = paper.decisions.create!
    newest_decision = paper.decisions.create!
    expect(newest_decision.revision_number).to eq 2
  end

  it "returns the correct revision number even if a revision number is provided while creating" do
    invalid_decision = paper.decisions.create! revision_number: 0
    expect(invalid_decision.revision_number).to eq 1
  end

  it "makes sure that the revision number is always unique" do
    invalid_decision = paper.decisions.create! # 1
    expect {
      invalid_decision.update_attribute :revision_number, 0
    }.to raise_error

    expect(invalid_decision.revision_number).to_not eq(1)
  end
end
