FactoryGirl.define do
  factory :answer do
    card_content
    paper
    owner factory: :cover_letter_task

    trait :with_task_owner do
      owner factory: :cover_letter_task
    end
  end
end
