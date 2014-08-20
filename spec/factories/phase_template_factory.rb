FactoryGirl.define do
  factory :phase_template do
    sequence(:name) { |n| "Phase #{n}" }
  end
end
