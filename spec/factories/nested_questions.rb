FactoryGirl.define do
  factory :nested_question do
    association :owner, factory: :task
    sequence(:ident) { |n| "ident_#{n}" }
    sequence(:position) { |n| n }
    sequence(:value) { |n| "value #{n}" }
    value_type "text"
  end
end
