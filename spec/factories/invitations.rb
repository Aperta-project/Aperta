require 'securerandom'

FactoryGirl.define do

  factory :invitation do
    sequence(:email) { |n| "foobar-#{n}@example.com" }
    code { SecureRandom.hex(4) }
    association(:task, factory: :task)
    association(:invitee, factory: :user)
    association(:actor, factory: :user)
    state "pending"
  end

end
