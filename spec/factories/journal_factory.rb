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

    trait(:with_paper) do
      after(:create) do |journal|
        FactoryGirl.create(:paper, journal: journal)
      end
    end

    after(:create) do |journal|
      JournalFactory.ensure_default_roles_and_permissions_exist(journal)
    end
  end

  sequence :doi_journal_prefix do
    |n| "JPREFIX#{n}"
  end

  sequence :doi_publisher_prefix do
    |n| "PPREFIX#{n}"
  end
end
