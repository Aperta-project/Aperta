require 'spec_helper'

describe "Journal" do
  it "will be valid with default factory data" do
    journal = build(:journal)
    expect(journal).to be_valid
  end
end
