FactoryGirl.define do
  factory :send_email_behavior do
    event_name 'paper_submitted'
    journal
  end

  factory :test_behavior do
    bool_attr { Faker::Boolean.boolean }
    string_attr { Faker::Lorem.sentence }
    journal
  end
end
