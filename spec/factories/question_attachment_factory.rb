FactoryGirl.define do
  factory :question_attachment, parent: :attachment, class: 'QuestionAttachment' do
    association :owner, factory: :nested_question_answer
  end
end
