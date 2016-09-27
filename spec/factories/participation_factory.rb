FactoryGirl.define do
  factory :participation do
    association :task, factory: :ad_hoc_task
    association :user
  end
end
