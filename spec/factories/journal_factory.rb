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

    doi_start_number "10000"
  end
end
