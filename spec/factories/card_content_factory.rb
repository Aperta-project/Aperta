FactoryGirl.define do
  factory :card_content do
    ident { "#{Faker::Lorem.word}--#{Faker::Lorem.word}" }
    value_type "text"
    after(:build) do |c|
      c.card_version = build(:card_version, card_contents: [c]) unless c.card_version.present?
    end

    trait :with_string_match_validation do
      after(:build) do |c|
        c.card_version = build(:card_version, card_contents: [c]) unless c.card_version.present?
        c.card_content_validations << build(:card_content_validation, :with_string_match_validation)
      end
    end
  end
end
