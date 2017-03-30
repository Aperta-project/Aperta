require 'digest'

FactoryGirl.define do
  factory :attachment, class: 'Attachment' do
    status "processing"
    file_hash { Digest::SHA256.hexdigest rand(10000).to_s(16) }
    association :owner, factory: :paper

    after :build do |attachment|
      attachment['file'] ||= 'factory-test-file.jpg'
    end

    before :create do |attachment|
      attachment.owner ||= FactoryGirl.create(:ad_hoc_task)
    end

    trait :processing do
      status "processing"
    end

    trait :errored do
      status "error"
      error_message "Failed for some reason"
    end

    trait :completed do
      status "done"
    end

    trait :unknown_state do
      status "unknown"
    end

    trait :with_resource_token do
      after :build do |attachment|
        attachment.build_resource_token(attachment.file)
      end
    end

    trait :with_task do
      association :owner, factory: :ad_hoc_task
    end

    trait :with_revise_task do
      association :owner, factory: :revise_task
    end
  end
end
