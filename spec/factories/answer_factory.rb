FactoryGirl.define do
  factory :answer do
    card_content

    trait :with_task_owner do
      owner factory: :cover_letter_task
      after(:build) { |answer| answer.paper = answer.owner.paper }
    end
  end
end
