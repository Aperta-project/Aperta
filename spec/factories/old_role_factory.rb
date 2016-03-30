FactoryGirl.define do
  factory :old_role do
    sequence(:name) { |n| "#{n.ordinalize} OldRole" }
    journal

    trait :admin do
      kind OldRole::ADMIN
      can_administer_journal true
      can_view_all_manuscript_managers true
    end

    trait :editor do
      kind OldRole::EDITOR
    end

    trait :custom do
      kind OldRole::CUSTOM
    end
  end
end
