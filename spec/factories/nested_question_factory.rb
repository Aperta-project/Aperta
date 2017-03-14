FactoryGirl.define do
  factory :old_nested_question, class: NestedQuestion do
    association :owner, factory: :ad_hoc_task
    sequence(:ident) { |n| "ident_#{n}" }
    sequence(:position) { |n| n }
    value_type "text"
  end
end
