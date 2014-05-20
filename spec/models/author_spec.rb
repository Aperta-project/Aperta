require 'spec_helper'

describe "Author" do
  it "will be valid with default factory data" do
    expect(FactoryGirl.build(:author)).to be_valid
  end
end
