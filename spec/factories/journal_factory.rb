FactoryGirl.define do
  factory :journal do
    sequence :name do |n|
      "Journal #{n}"
    end

    sequence :doi_journal_prefix do
      |n| "JPREFIX#{n}"
    end

    sequence :doi_publisher_prefix do
      |n| "PPREFIX#{n}"
    end

    last_doi_issued "10000"
  end
end
