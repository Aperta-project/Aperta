FactoryGirl.define do
  factory :journal do
    sequence :name do |n|
      "Journal #{n}"
    end
  end
end
