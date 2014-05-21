FactoryGirl.define do
  factory :affiliation do
    affiliable { build(:user) }
    sequence :name do |n|
      "Affiliation #{n}"
    end

    trait(:author) do
      affiliable { build(:author) }
    end
  end
end
