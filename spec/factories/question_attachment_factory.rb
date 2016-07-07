FactoryGirl.define do
  factory :question_attachment, parent: :attachment, class: 'QuestionAttachment' do
    association :owner, factory: :nested_question_answer

    trait :with_fake_attachment do
      after :build do |attachment|
        attachment.file = File.open(Rails.root.join('spec/fixtures/yeti.tiff'))
      end
    end

    trait :with_resource_token do
      after :create do |attachment|
        FactoryGirl.create(:resource_token, owner: attachment)
      end
    end
  end
end
