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

    trait(:with_roles_and_permissions) do
      after(:create) do |journal|
        JournalFactory.ensure_default_roles_and_permissions_exist(journal)
      end
    end

    %w(
      academic_editor creator collaborator cover_editor discussion_participant
      handling_editor internal_editor reviewer publishing_services staff_admin
      task_participant
    ).each do |role|
      role_method = "#{role}_role"
      trait("with_#{role_method}".to_sym) do
        after(:create) do |journal|
          journal.send(role_method) ||
            journal.send("create_#{role_method}!")
        end
      end
    end

    %w(publishing_services staff_admin).each do |role|
      trait("with_#{role}_user".to_sym) do
        after(:create) do |journal|
          FactoryGirl.create(:assignment,
                             role: journal.send("#{role}_role".to_sym),
                             user: FactoryGirl.build(:user),
                             assigned_to: journal)
        end
      end
    end

    factory :journal_with_roles_and_permissions, traits: [:with_roles_and_permissions]
  end

  sequence :doi_journal_prefix do
    |n| "JPREFIX#{n}"
  end

  sequence :doi_publisher_prefix do
    |n| "PPREFIX#{n}"
  end
end
