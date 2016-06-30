require 'digest'

FactoryGirl.define do
  factory :attachment, class: 'Attachment' do
    status "processing"
    file_hash { Digest::SHA256.hexdigest rand(10000).to_s(16) }

    after :build do |attachment|
      attachment['file'] ||= 'factory-test-file.jpg'
    end

    trait :with_resource_token do
      after :build do |attachment|
        attachment.resource_token ||= FactoryGirl.build(:resource_token, owner: attachment)
      end
    end
  end

  factory :adhoc_attachment, parent: :attachment, class: 'AdhocAttachment' do
    trait :with_task do
      association :owner, factory: :task
    end
  end
end
