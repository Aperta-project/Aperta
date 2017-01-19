FactoryGirl.define do
  factory :nested_question do
    association :owner, factory: :ad_hoc_task
    sequence(:ident) { |n| "ident_#{n}" }
    sequence(:position) { |n| n }
    value_type "text"

    transient do
      parent nil
    end

    after(:create) do |q, evaluator|
      q.move_to_child_of(evaluator.parent) if evaluator.parent.present?
    end
  end
end
