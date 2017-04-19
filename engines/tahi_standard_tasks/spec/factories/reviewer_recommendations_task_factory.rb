FactoryGirl.define do
  factory :reviewer_recommendations_task, class: 'TahiStandardTasks::ReviewerRecommendationsTask' do
    paper
    phase
    card_version
    title "Reviewer Candidates"
  end
end
