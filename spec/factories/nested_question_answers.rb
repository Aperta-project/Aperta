FactoryGirl.define do
  factory :nested_question_answer do
    association :nested_question
    sequence(:value){ |n| "value #{n}" }
    value_type "text"

    after(:build) do |nested_question_answer, evaluator|
      unless evaluator.nested_question.owner
        nested_question_answer.owner = evaluator.nested_question.owner
      end
    end
  end
end
