FactoryGirl.define do
  factory :similarity_check do
    versioned_text

    trait :waiting_for_report do
      state :waiting_for_report
      ithenticate_document_id { Faker::Number.number(8).to_i }
      timeout_at { Time.now.utc + 10.minutes }
    end

    trait :report_complete do
      state :report_complete
      ithenticate_document_id { Faker::Number.number(8).to_i }
      report_id { Faker::Number.number(8).to_i }
    end
  end
end
