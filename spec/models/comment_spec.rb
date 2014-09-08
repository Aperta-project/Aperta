require 'spec_helper'

describe Comment do
  context "validation" do
    it "will be valid with default factory data" do
      model = FactoryGirl.build(:comment)
      expect(model).to be_valid
    end
  end
end
