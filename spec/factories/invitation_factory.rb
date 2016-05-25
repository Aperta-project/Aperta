require 'securerandom'

FactoryGirl.define do
  factory :invitation do
    invitee_role 'Some Role'

    association(:task, factory: :invitable_task)
    association(:invitee, factory: :user)
    association(:actor, factory: :user)
    association(:decision, factory: :decision)

    after(:build) do |invitation, evaluator|
      if evaluator.invitee && invitation.email.nil?
        invitation.email = evaluator.invitee.email
      end
      invitation.body = "You've been invited to"
    end

    trait :invited do
      state "invited"
    end

    trait :accepted do
      state "accepted"
    end

    trait :rejected do
      state "rejected"
    end
  end
end
