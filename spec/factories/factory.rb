FactoryGirl.define do
  sequence :email do |n|
    "test-user#{n}@example.com"
  end

  sequence :username do |n|
    "test-user#{n}"
  end

  factory :user do
    username
    first_name { ['Zoey', 'Albert', 'Steve'].sample }
    last_name { ['Bob', 'Einstein', 'Windham'].sample }
    email
    password 'password'
    password_confirmation 'password'
    affiliation { ['PLOS', 'Universität Zürich'].sample }
    admin false
    trait :admin do
      admin true
    end
  end

  factory :paper do
    short_title 'Test Paper'
    journal
  end

  factory :journal do
    name "Test Journal"
  end

  factory :message_task, class: StandardTasks::MessageTask do
    title "a subject" # should match subject
    message_subject "a subject"
  end

  factory :comment do
    body "HEY"
  end

end
