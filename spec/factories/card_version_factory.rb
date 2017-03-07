FactoryGirl.define do
  factory :card_version do
    card
    version 1

    after(:build) do |v|
      v.card_content = create(:card_content, card: v.card)
    end
  end
end
