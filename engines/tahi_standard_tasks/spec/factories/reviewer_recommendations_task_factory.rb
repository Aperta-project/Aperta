FactoryGirl.define do
  factory :reviewer_recommendations_task, class: 'TahiStandardTasks::ReviewerRecommendationsTask' do
    paper
    phase
    title "Reviewer Candidates"
    old_role "author"
  end
end
