FactoryGirl.define do
  factory :reviewer_recommendations_task, class: 'TahiStandardTasks::ReviewerRecommendationsTask' do
    phase
    title "Revise Manusript"
    role "author"
  end
end
