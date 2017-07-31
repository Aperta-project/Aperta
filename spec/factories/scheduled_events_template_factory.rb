FactoryGirl.define do
  factory :scheduled_event_template do
    # owner ['ReviewerReport', 'Invitation'].sample
    owner 'ReviewerReport'
    event_name Faker::Pokemon.name + 'Chaser'
    event_dispatch_offset Faker::Number.between(1, 4) * [1, -1].sample
  end
end
