FactoryGirl.define do
  factory :repetition do
    card_content
    association :task, factory: :custom_card_task
  end
end
