FactoryGirl.define do
  factory :affiliation do
    user
    sequence :email do |n|
      "#{n}@affiliation.com"
    end
    sequence :name do |n|
      "Affiliation #{n}"
    end
  end
end
