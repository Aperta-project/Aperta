# Many roles are defined on the journal level. See the journal_factory
# helpers for traits that assist with setting up specific roles. They
# are typically named like "with_<role_name>_role", e.g. with_creator_role
FactoryGirl.define do
  factory :role do
    sequence(:name){ |i| "Role #{i}" }
    journal
    participates_in_papers true
    participates_in_tasks true

    trait :site_admin do
      name Role::SITE_ADMIN_ROLE
      journal { nil }
      participates_in_papers false
      participates_in_tasks false

      after(:create) do |role|
        role.ensure_permission_exists(
          Permission::WILDCARD, applies_to: System.name
        )
      end
    end
  end
end
