FactoryGirl.define do
  factory :feature_flag do
    sequence(:name) { |i| "Feature #{i}" }
    active true
  end
end
