FactoryGirl.define do
  factory :question do
    question "To be or not to be"
    task
    sequence(:ident) { |n| "question.#{n.ordinalize}" }
  end
end
