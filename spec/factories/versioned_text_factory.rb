require 'securerandom'

FactoryGirl.define do
  factory :versioned_text do
    major_version 1
    minor_version 0
    paper
    text "Now, this is the story all about how my life got flipped-turned upside down"
  end
end
