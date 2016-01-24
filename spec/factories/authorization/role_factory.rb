FactoryGirl.define do
  factory :role do
    sequence(:name){ |i| "Role #{i}" }
    journal
    participates_in_papers true
    participates_in_tasks true

    trait :creator do
      name Role::CREATOR_ROLE
    end

    trait :collaborator do
      name Role::CREATOR_ROLE
    end
  end
end
