FactoryGirl.define do
  factory :question_attachment do
    association :owner, factory: :nested_question_answer

    trait :with_fake_attachment do
      after :build do |attachment|
        attachment[:file] = "some-attachment.png"
      end
    end
  end
end
