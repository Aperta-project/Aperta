FactoryGirl.define do
  factory :task_template do
    title "my task name"
    journal_task_type
    card nil

    trait :with_card do
      journal_task_type nil
      card
    end
  end
end
