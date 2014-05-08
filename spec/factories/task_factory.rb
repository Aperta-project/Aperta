FactoryGirl.define do
  factory :message_task do
    title "a subject" # should match subject
  end

  factory :reviewer_report_task do
    association :assignee, factory: :user
    phase
  end
end
