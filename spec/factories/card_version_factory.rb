FactoryGirl.define do
  factory :card_version do
    card
    version 1

    after(:build) do |v|
      v.card_contents << build(:card_content, card_version: v, content_type: 'display-children', value_type: nil) if v.card_contents.count.zero?
    end
  end
end
