FactoryGirl.define do
  factory :nested_question_answer do
    paper
    nested_question
    sequence(:value) { |n| "value #{n}" }
    value_type "text"

    trait :boolean_yes do
      after(:build) do |answer|
        answer.value = NestedQuestionAnswer::YES
        answer.value_type = 'boolean'
      end
    end
  end
end
