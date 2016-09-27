FactoryGirl.define do
  factory :participation do
    association :ad_hoc_task
    association :user
  end
end
