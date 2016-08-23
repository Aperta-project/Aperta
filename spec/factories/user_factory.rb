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
    site_admin false

    trait :site_admin do
      site_admin true
    end

    trait :with_affiliation do
      after(:create) do |user, evaluator|
        create(:affiliation, user: user)
      end
    end

    # This is a kluge.  For some reason the wildcard state is being deleted sometimes
    # between test runs, but the permission itself exists.  This fixes that scenario.
    # I'm open to better ideas.
    trait :with_view_profile do
      after(:create) do |user|
        view_profile_permission = Permission.find_by(action: "view_profile")
        if view_profile_permission.states.empty?
          view_profile_permission.states << PermissionState.find_by(name: "*")
        end
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
