require 'rails_helper'

describe TahiStandardTasks::ReviewerRecommendation do
  subject(:recommendation) { FactoryGirl.build(:reviewer_recommendation) }

  describe "validations" do
    it "is valid" do
      expect(recommendation.valid?).to be(true)
    end

    it "requires an :first_name" do
      recommendation.first_name = nil
      expect(recommendation.valid?).to be(false)
    end

    it "requires an :last_name" do
      recommendation.last_name = nil
      expect(recommendation.valid?).to be(false)
    end
    it "requires an :email" do
      recommendation.email = nil
      expect(recommendation.valid?).to be(false)
    end
  end
end
