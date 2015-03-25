require 'securerandom'

FactoryGirl.define do
  factory :invitation do

    association(:task, factory: :task)

    trait :invited do
      state "invited"
      code { SecureRandom.hex(4) }
      association(:invitee, factory: :user)
      association(:actor, factory: :user)
      after(:build) do |invitation, evaluator|
        invitation.email = evaluator.invitee.email
      end

    end
  end
end
