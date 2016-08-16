FactoryGirl.define do
  factory :decision do
    association :paper, factory: :paper
    sequence(:major_version) { |n| n }
    sequence(:minor_version) { |n| n }
    registered_at DateTime.now.utc
    letter 'Test Decision Letter'
    verdict 'accept'

    trait :pending do
      verdict nil
      letter nil
      major_version nil
      minor_version nil
    end

    trait :rejected do
      verdict 'reject'
    end

    trait :major_revision do
      verdict 'major_revision'
    end
  end
end
