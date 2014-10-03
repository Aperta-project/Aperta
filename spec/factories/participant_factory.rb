FactoryGirl.define do
  factory :participation do
    association :task
    association :participant, factory: :user
  end
end
