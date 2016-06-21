FactoryGirl.define do
  factory :attachment, class: 'Attachment' do
    status "processing"
  end

  factory :adhoc_attachment, class: 'AdhocAttachment' do
    status "processing"

    trait :with_task do
      association :owner, factory: :task
    end
  end
end
