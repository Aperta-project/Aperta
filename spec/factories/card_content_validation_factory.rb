FactoryGirl.define do
  factory :card_content_validation do
    # default
    validator { '/text/' }
    validation_type { 'string-match' }

    trait :with_string_match_validation do
      validator { '/text/' }
      validation_type { 'string-match' }
      error_message { 'oh noes!' }
    end
  end
end
