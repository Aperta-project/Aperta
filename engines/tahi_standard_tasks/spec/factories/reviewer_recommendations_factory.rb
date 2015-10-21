FactoryGirl.define do
  factory :reviewer_recommendation, class: 'TahiStandardTasks::ReviewerRecommendation' do
    first_name "Bob"
    middle_initial "J."
    last_name "Jones"
    email "bob.j.jones@example.com"
    title "Director"
    department "Department Of Somewhere"
    affiliation "Universe"
    recommend_or_oppose "Recommend"
    reviewer_recommendations_task
  end
end
