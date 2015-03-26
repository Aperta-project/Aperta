require 'rails_helper'

describe Decision do
  let(:paper) { FactoryGirl.create :paper }

  let!(:decision) { paper.decisions.create! }

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

  it "does not create multiple records with the same revision number for the paper" do
    decision = paper.decisions.create!

    # Nothing is raised here,
    # because we reassign revision_number on Decision.before_save
    duplicate_decision = paper.decisions.create!({
      revision_number: 0
    })

    expect(duplicate_decision.revision_number).to eq 2
  end
end
