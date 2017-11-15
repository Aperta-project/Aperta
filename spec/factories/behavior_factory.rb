FactoryGirl.define do
  factory :send_email_behavior do
    event_name 'paper_submitted'
    journal
  end
end
