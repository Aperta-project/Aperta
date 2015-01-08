require 'rails_helper'

describe "Author" do
  it "is valid with default factory data" do
    expect(FactoryGirl.build(:author)).to be_valid
  end
end
