FactoryGirl.define do
  factory :correspondence do
    body       Faker::Lorem.paragraph
    sender     Faker::Internet.safe_email
    recipients Faker::Internet.safe_email
    sent_at    DateTime.now.in_time_zone
    sequence(:subject) { |n| "Correspondence Subject #{n}" }

    association :paper, factory: :paper

    trait :with_journal do
      association :journal, factory: :journal
    end

    trait :with_task do
      association :task, factory: :ad_hoc_task
    end

    trait :as_external do
      bcc         Faker::Internet.safe_email
      cc          Faker::Internet.safe_email
      description Faker::Lorem.sentence
    end
  end
end
