FactoryGirl.define do
  factory :card_content do
    ident { "#{Faker::Lorem.word}--#{Faker::Lorem.word}" }
    value_type "text"
    after(:build) do |c|
      c.card_version = build(:card_version, card_contents: [c]) if c.card_version.blank?
    end

    trait :root do
      parent_id nil
    end

    trait :with_child do
      after(:create) do |root_content|
        child = FactoryGirl.create(:card_content)
        child.move_to_child_of(root_content)
        root_content.reload
      end
    end

    trait :with_string_match_validation do
      after(:build) do |c|
        c.card_version = build(:card_version, card_contents: [c]) if c.card_version.blank?
        c.card_content_validations << build(:card_content_validation, :with_string_match_validation)
      end
    end
  end
end
