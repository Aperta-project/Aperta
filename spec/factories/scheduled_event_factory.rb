FactoryGirl.define do
  factory :scheduled_event do
    due_datetime
    dispatch_at DateTime.now.utc
    name 'Reminder'
  end
end
