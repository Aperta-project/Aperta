require 'spec_helper'

describe "Participation" do
  it "will be valid with default factory data" do
    participation = build(:participation)
    expect(participation).to be_valid
  end
end
