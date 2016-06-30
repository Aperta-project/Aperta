FactoryGirl.define do
  factory :question_attachment, parent: :attachment, class: 'QuestionAttachment' do
    association :owner, factory: :nested_question_answer

    trait :with_fake_attachment do
      after :build do |attachment|
        attachment.file = File.open(Rails.root.join('spec/fixtures/yeti.tiff'))
      end
    end
  end
end
