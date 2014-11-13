FactoryGirl.define do
  factory :flow do
    user
    sequence(:title) { |s| "Flow #{s}" }
  end
end
