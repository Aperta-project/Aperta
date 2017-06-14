require 'digest'

FactoryGirl.define do
  factory :decision_attachment, class: 'decisionAttachment' do
    status "processing"
    file_hash { Digest::SHA256.hexdigest rand(10_000).to_s(16) }
    association :owner, factory: :decision

    after :build do |attachment|
      attachment['file'] ||= 'factory-test-file.jpg'
    end

    before :create do |attachment|
      attachment.owner ||= FactoryGirl.create(:ad_hoc_task)
    end
  end
end
