require 'rails_helper'

context "validation" do
  it "will be valid with default factory data" do
    model = FactoryGirl.build(:bibitem)
    expect(model).to be_valid
  end
end
