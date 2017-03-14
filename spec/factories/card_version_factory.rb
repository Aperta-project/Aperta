FactoryGirl.define do
  factory :card_version do
    card
    version 1

    after(:build) do |v|
      v.card_contents << build(:card_content)
    end
  end
end
