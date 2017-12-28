require 'rails_helper'

describe TahiStandardTasks::ReviewerRecommendation do
  describe "validations" do
    let(:recommendation) { FactoryGirl.build(:reviewer_recommendation) }

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

  describe "#paper" do
    let(:recommendation) { FactoryGirl.create(:reviewer_recommendation) }

    it "always proxies to paper" do
      expect(recommendation.paper).to eq(recommendation.reviewer_recommendations_task.paper)
    end
  end

  describe '#task' do
    let!(:task) { FactoryGirl.create(:reviewer_recommendations_task) }
    let!(:recommendation) do
      FactoryGirl.create(
        :reviewer_recommendation,
        reviewer_recommendations_task: task
      )
    end

    it 'always proxies to reviewer_recommendations_task' do
      expect(recommendation.task)
        .to eq(recommendation.reviewer_recommendations_task)
    end
  end
end
