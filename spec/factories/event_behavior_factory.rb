FactoryGirl.define do
  factory :event_behavior do
    event_name 'paper:submitted'
    action 'send_email'
    journal
  end
end
