FactoryGirl.define do
  factory :nested_question_answer do
    sequence(:value) { |n| "value #{n}" }
    value_type "text"
    association :nested_question

    trait :boolean_yes do
      after(:build) do |answer|
        answer.value = NestedQuestionAnswer::YES
        answer.value_type = 'boolean'
      end
    end
  end
end
