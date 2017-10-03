FactoryGirl.define do
  factory :scheduled_event do
    due_datetime
    dispatch_at DateTime.now.utc
    name 'Reminder'

    trait :active do
      state 'active'
    end

    trait :passive do
      state 'passive'
    end
  end
end
