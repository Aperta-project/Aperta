FactoryGirl.define do
  factory :paper do
    journal
    sequence :short_title do |n|
      "Test Paper #{n}"
    end
  end
end
