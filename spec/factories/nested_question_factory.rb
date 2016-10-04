FactoryGirl.define do
  factory :nested_question do
    association :owner, factory: :ad_hoc_task
    sequence(:ident) { |n| "ident_#{n}" }
    sequence(:position) { |n| n }
    value_type "text"
  end
end
