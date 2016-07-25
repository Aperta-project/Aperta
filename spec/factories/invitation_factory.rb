require 'securerandom'

FactoryGirl.define do
  factory :invitation do
    invitee_role 'Some Role'
    email "email@example.com"
    token { SecureRandom.hex(10) }
    association(:task, factory: :invitable_task)
    association(:invitee, factory: :user)
    association(:actor, factory: :user)
    association(:decision, factory: :decision)

    after(:build) do |invitation, evaluator|
      invitation.email = evaluator.invitee.email if evaluator.invitee
      invitation.body = "You've been invited to"
    end

    trait :invited do
      state "invited"
    end

    trait :accepted do
      state "accepted"
    end

    trait :declined do
      state "declined"
    end
  end
end
