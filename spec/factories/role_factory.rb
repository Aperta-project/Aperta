FactoryGirl.define do
  factory :role do
    sequence(:name) { |n| "#{n.ordinalize} Role" }

    trait :admin do
      admin true
    end

    trait :editor do
      editor true
    end

    trait :reviewer do
      reviewer true
    end
  end
end
