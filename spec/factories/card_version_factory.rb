FactoryGirl.define do
  factory :card_version do
    card
    version 1

    after(:create) do |v|
      v.card_contents << create(:card_content, card_version: v) if v.card_contents.count.zero?
    end
  end
end
