FactoryGirl.define do
  factory :similarity_check do
    versioned_text

    trait :waiting_for_report do
      state :waiting_for_report
      ithenticate_document_id { Faker::Number.number(8).to_i }
    end
  end
end
