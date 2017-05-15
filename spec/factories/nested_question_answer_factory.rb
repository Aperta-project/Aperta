FactoryGirl.define do
  factory :old_nested_question_answer, class: NestedQuestionAnswer do
    sequence(:value) { |n| "value #{n}" }
    value_type "text"
    paper

    trait :boolean_yes do
      after(:build) do |answer|
        answer.value = NestedQuestionAnswer::YES
        answer.value_type = 'boolean'
      end
    end

    trait :with_task_owner do
      owner factory: :cover_letter_task
    end

    trait :with_attachment do
      after(:create) do |answer|
        FactoryGirl.create(:question_attachment, owner: answer)
      end
    end
  end
end
