FactoryGirl.define do
  factory :author_group do
    sequence :name do |n|
      "#{n.ordinalise.capitalize} Author"
    end
  end
end
