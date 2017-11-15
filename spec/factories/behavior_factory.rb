FactoryGirl.define do
  factory :behavior do
    event_name 'paper_submitted'
    action 'send_email'
    journal
  end

  factory :send_email_behavior do
    event_name 'paper_submitted'
    journal
  end
end
