FactoryGirl.define do
  factory :affiliation do
    user
    sequence :name do |n|
      "Affiliation #{n}"
    end
  end
end
