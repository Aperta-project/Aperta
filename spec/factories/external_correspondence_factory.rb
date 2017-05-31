FactoryGirl.define do
  factory :external_correspondence do
    association :paper, factory: :paper
    sender      "#{Faker::Name.name} <#{Faker::Internet.safe_email}>"
    recipients  "#{Faker::Name.name} <#{Faker::Internet.safe_email}>"
    description Faker::Lorem.sentence
    cc          "#{Faker::Name.name} <#{Faker::Internet.safe_email}>"
    bcc         "#{Faker::Name.name} <#{Faker::Internet.safe_email}>"
    content     Faker::Lorem.paragraph
    sent_at     DateTime.now.in_time_zone
    sequence(:subject) { |n| "Correspondence Subject #{n}" }
  end
end
