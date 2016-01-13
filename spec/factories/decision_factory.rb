FactoryGirl.define do
  factory :decision do
    association :paper, factory: :paper
    sequence(:revision_number) { |n| n }
    letter 'Test Decision Letter'
    verdict 'accept'

    trait :pending do
      verdict nil
      letter nil
    end

    trait :rejected do
      verdict 'reject'
    end

    trait :major_revision do
      verdict 'major_revision'
    end
  end
end
