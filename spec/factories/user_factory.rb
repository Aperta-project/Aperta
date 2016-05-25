FactoryGirl.define do
  sequence :email do |n|
    "test-user-#{n}@example.com"
  end

  sequence :username do |n|
    "testuser#{n}"
  end

  sequence :last_name do |n|
    "Smith#{n}"
  end

  sequence :first_name do |n|
    "Henry#{n}"
  end

  sequence :ned_id do |n|
    100 + n
  end

  factory :user do
    username
    first_name
    last_name
    email
    password 'password'
    password_confirmation 'password'
    ned_id
    site_admin false

    trait :site_admin do
      site_admin true
    end

    trait :with_affiliation do
      after(:create) do |user, evaluator|
        create(:affiliation, user: user)
      end
    end

    trait :orcid do
      credentials { [create(:orcid_credential)] }
    end

    trait :cas do
      credentials { [create(:cas_credential)] }
    end
  end
end
