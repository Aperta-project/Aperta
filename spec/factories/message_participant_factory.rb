FactoryGirl.define do
  factory :message_participant do
    association :task, factory: :message_task
    association :participant, factory: :user
  end
end
