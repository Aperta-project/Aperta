FactoryGirl.define do
  factory :task_template do
    title "my task name"
    journal_task_type
    card nil

    trait :with_card do
      journal_task_type nil
      card
    end

    trait :with_setting do
      transient do
        setting_klass ""
        setting_name ""
      end

      after(:create) do |template, evaluator|
        evaluator.setting_klass.constantize.create(name: evaluator.setting_name, owner: template)
      end
    end
  end
end
