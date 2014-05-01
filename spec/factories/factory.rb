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
    admin false
    trait :admin do
      admin true
    end
  end

  factory :message_task do
    title "a subject" # should match subject
  end

  factory :comment do
    body "HEY"
  end

  factory :survey do
    question "What is the cake?"
    answer "A lie!"
  end

  factory :manuscript_manager_template do
    name 'Sample Template'
    paper_type 'Research'
    template { {} }

  end

end
