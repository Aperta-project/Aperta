FactoryGirl.define do
  factory :question_attachment do
    association :nested_question_answer

    trait :with_fake_attachment do
      after :build do |attachment|
        attachment[:attachment] = "some-attachment.png"
      end
    end
  end
end
