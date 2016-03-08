FactoryGirl.define do
  factory :role do
    sequence(:name){ |i| "Role #{i}" }
    journal
    participates_in_papers true
    participates_in_tasks true

    trait :creator do
      fail 'Use Role.creator instead of this factory'
    end

    trait :collaborator do
      fail 'Use Role.collaborator instead of this factory'
    end

    trait :task_participant do
      name Role::TASK_PARTICIPANT_ROLE
    end
  end
end
