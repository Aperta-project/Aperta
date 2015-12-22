FactoryGirl.define do
  factory :role do
    sequence(:name){ |i| "Role #{i}" }
    participates_in_papers true
    participates_in_tasks true
  end
end
