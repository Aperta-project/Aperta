FactoryGirl.define do
  factory :question_attachment do
    association :question, factory: :nested_question_answer

    trait :with_fake_attachment do
      after :build do |attachment|
        attachment[:attachment] = "some-attachment.png"
      end
    end
  end

  factory :question_attachment_with_task_owner, class: "QuestionAttachment" do
    association :question, factory: :nested_question_answer

    after :build do |attachment|
      attachment.question.update owner: FactoryGirl.build(:task)
    end
  end
end
