require 'securerandom'

FactoryGirl.define do
  factory :versioned_text do
    text "Now, this is the story all about how my life got flipped-turned upside down"
    copy_on_edit false

    trait(:copy_on_edit) do
      copy_on_edit true
    end
  end
end
