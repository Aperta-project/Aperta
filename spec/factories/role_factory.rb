FactoryGirl.define do
  factory :role do
    name "A Role"

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
