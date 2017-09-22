require 'rails_helper'

describe Repetition do
  describe "validations" do
    it "has a valid factory" do
      repetition = FactoryGirl.build(:repetition)
      expect(repetition).to be_valid
    end
  end
end
