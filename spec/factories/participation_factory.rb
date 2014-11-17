FactoryGirl.define do
  factory :participation do
    association :task
    association :user
  end
end
