require 'digest'

FactoryGirl.define do
  factory :attachment, class: 'Attachment' do
    status "processing"
    file_hash { Digest::SHA256.hexdigest rand(10000).to_s(16) }
  end

  factory :adhoc_attachment, class: 'AdhocAttachment' do
    status "processing"
    file_hash { Digest::SHA256.hexdigest rand(10000).to_s(16) }

    trait :with_task do
      association :owner, factory: :task
    end
  end
end
