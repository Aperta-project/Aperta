FactoryGirl.define do
  factory :attachment do
    status "processing"

    trait :with_task do
      association :task
    end
  end
end
