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

  sequence :ned_id, 100

  factory :user do
    username
    first_name
    last_name
    email
    password 'password'
    password_confirmation 'password'
    ned_id

    trait :site_admin do
      after(:create) do |user, evaluator|
        role = Role.site_admin_role || FactoryGirl.create(:role, :site_admin)
        user.assign_to! assigned_to: System.first_or_create!, role: role
      end
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
