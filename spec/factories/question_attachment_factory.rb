FactoryGirl.define do
  factory :question_attachment, parent: :attachment, class: 'QuestionAttachment' do
    association :owner, factory: :answer
  end
end
