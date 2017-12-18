FactoryGirl.define do
  factory :phase do
    sequence(:name) { |n| "Phase #{n}" }
    paper
    sequence(:position)
  end
end
