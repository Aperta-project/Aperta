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

    trait :with_string_length_minimum_validation do
      validator { '10' }
      validation_type { 'string-length-minimum' }
      error_message { 'must be at least 10 characters long' }
    end

    trait :with_string_length_maximum_validation do
      validator { '10' }
      validation_type { 'string-length-maximum' }
      error_message { 'must be at less than 10 characters long' }
    end
  end
end
