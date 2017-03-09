FactoryGirl.define do
  factory :card_content do
    ident { "#{Faker::Lorem.word}--#{Faker::Lorem.word}" }
    value_type "text"

    after(:build) do |c|
      c.card = if c.parent.present? && c.card.blank?
                 c.parent.card
               else
                 FactoryGirl.build(:card)
               end
    end
  end
end
