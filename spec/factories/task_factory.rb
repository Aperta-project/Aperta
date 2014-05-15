FactoryGirl.define do
  factory :task do
    title "Do something awesome"
    role 'admin'
    phase
  end

  factory :message_task do
    title "a subject" # should match subject
  end

  factory :reviewer_report_task do
    association :assignee, factory: :user
    phase
  end
end
