FactoryGirl.define do
  factory :card_content do
    ident { "#{Faker::Lorem.word}--#{Faker::Lorem.word}" }
    value_type "text"
  end
end
