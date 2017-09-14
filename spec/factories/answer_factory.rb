FactoryGirl.define do
  factory :answer do
    card_content
    paper
    owner factory: :ad_hoc_task

    trait :with_task_owner do
      owner factory: :ad_hoc_task
    end
  end
end
