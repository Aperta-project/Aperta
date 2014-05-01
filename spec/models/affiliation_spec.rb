require 'spec_helper'

describe "Affiliation" do
  it "will be valid with default factory data" do
    affiliation = FactoryGirl.build(:affiliation)
    expect(affiliation).to be_valid
  end
end
