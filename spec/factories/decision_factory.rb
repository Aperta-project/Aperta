FactoryGirl.define do
  factory :decision do
    association :paper, factory: :paper
    sequence(:revision_number) { |n| n }
    letter 'Test Decision Letter'
    verdict 'accept'
  end
end
