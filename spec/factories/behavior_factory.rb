FactoryGirl.define do
  factory :send_email_behavior do
    event_name 'paper_submitted'
    journal
  end

  factory :create_task_behavior do
    event_name 'paper_submitted'
    journal
  end

  factory :task_completion_behavior do
    event_name 'task_complete'
    journal
  end

  factory :test_behavior do
    bool_attr { Faker::Boolean.boolean }
    string_attr { Faker::Lorem.sentence }
    journal
  end
end
