FactoryGirl.define do
  factory :author do
    first_name "Luke"
    last_name "Skywalker"
    position 1

    trait :with_paper do
      association :paper
    end
  end
end
