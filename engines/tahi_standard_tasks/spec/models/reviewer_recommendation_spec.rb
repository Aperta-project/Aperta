require 'rails_helper'

describe TahiStandardTasks::ReviewerRecommendation do
  let(:task) { FactoryGirl.create(:reviewer_recommendations_task, completed: true) }
  let(:recommendation) do
    FactoryGirl.build(:reviewer_recommendation, reviewer_recommendations_task: task)
  end
  describe "validations when the task is complete" do
    it "is valid" do
      expect(recommendation.valid?).to be(true)
    end

    it "requires a :first_name" do
      recommendation.first_name = nil
      expect(recommendation.valid?).to be(false)
    end

    it "requires a :last_name" do
      recommendation.last_name = nil
      expect(recommendation.valid?).to be(false)
    end
    it "requires an :email" do
      recommendation.email = nil
      expect(recommendation.valid?).to be(false)
    end
  end

  describe "validations when the task is not complete" do
    let(:task) { FactoryGirl.create(:reviewer_recommendations_task, completed: false) }
    it "is valid" do
      expect(recommendation.valid?).to be(true)
    end

    it "does not require a :first_name" do
      recommendation.first_name = nil
      expect(recommendation.valid?).to be(true)
    end

    it "does not require a :last_name" do
      recommendation.last_name = nil
      expect(recommendation.valid?).to be(true)
    end
    it "does not require an :email" do
      recommendation.email = nil
      expect(recommendation.valid?).to be(true)
    end
  end

  describe "#paper" do
    it "always proxies to paper" do
      expect(recommendation.paper).to eq(recommendation.reviewer_recommendations_task.paper)
    end
  end

  describe '#task' do
    it 'always proxies to reviewer_recommendations_task' do
      expect(recommendation.task)
        .to eq(recommendation.reviewer_recommendations_task)
    end
  end
end
