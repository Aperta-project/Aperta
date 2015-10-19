FactoryGirl.define do
  factory :journal do
    sequence :name do |n|
      "Journal #{n}"
    end

    trait :with_doi do
      doi_journal_prefix
      doi_publisher_prefix
      last_doi_issued "10000"
    end
  end

  sequence :doi_journal_prefix do
    |n| "JPREFIX#{n}"
  end

  sequence :doi_publisher_prefix do
    |n| "PPREFIX#{n}"
  end
end
