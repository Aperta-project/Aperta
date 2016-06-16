require 'rails_helper'

describe TahiStandardTasks::ReviewerRecommendationsTask do
  subject(:task) { FactoryGirl.create(:reviewer_recommendations_task) }

  describe '.restore_defaults' do
    include_examples '<Task class>.restore_defaults update title to the default'
    include_examples '<Task class>.restore_defaults update old_role to the default'
  end

  describe '#reviewer_recommendations association' do
    let!(:recommendation) do
      FactoryGirl.create(
        :reviewer_recommendation,
        reviewer_recommendations_task: task
      )
    end

    it 'is destroyed when its associated task is destroyed' do
      expect do
        task.destroy
      end.to change { task.reviewer_recommendations.count }.by(-1)

      expect { recommendation.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
