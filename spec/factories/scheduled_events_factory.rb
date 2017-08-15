def create_offset
  (1..4).to_a.sample * [1, -1].sample
end

FactoryGirl.define do
  factory :scheduled_events do
    association due_datetime, :in_5_days
    name Faker::Pokemon.name + 'Chaser'
    state nil
    dispatch DateTime.now.utc + create_offset.days
  end
end
