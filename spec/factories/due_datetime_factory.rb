# coding: utf-8
FactoryGirl.define do
  factory :due_datetime do
    due_at nil
    originally_due_at nil

    trait :in_5_days do
      due_at DateTime.now.utc + 5.days
      originally_due_at DateTime.now.utc + 5.days
    end
  end
end
