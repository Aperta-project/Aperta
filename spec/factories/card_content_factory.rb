FactoryGirl.define do
  factory :card_content do
    card
    ident { "#{Faker::Lorem.word}--#{Faker::Lorem.word}" }
  end
end
