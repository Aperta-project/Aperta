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
    user_settings { UserSettings.new flows: ['Up for grabs', 'My Tasks', 'My Papers', 'Done'] }
    admin false
    trait :admin do
      admin true
    end
  end
end
