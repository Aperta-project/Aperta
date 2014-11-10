FactoryGirl.define do
  factory :role do
    sequence(:name) { |n| "#{n.ordinalize} Role" }

    trait :admin do
      kind Role::ADMIN
      can_administer_journal true
      can_view_all_manuscript_managers true
    end

    trait :editor do
      kind Role::EDITOR
    end

    trait :reviewer do
      kind Role::REVIEWER
    end

    trait :flow_manager do
      kind Role::FLOW_MANAGER
      can_view_flow_manager true
    end

    trait :custom do
      kind Role::CUSTOM
    end
  end
end
