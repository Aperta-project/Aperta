require 'rails_helper'

describe Activity do
  it "will be valid with default factory data" do
    expect(build(:activity)).to be_valid
  end
end
