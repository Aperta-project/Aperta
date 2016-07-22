FactoryGirl.define do
  factory :invitation do
    invitee_role 'Some Role'
    paper { build(:paper) }
    task { build(:invitable_task, paper: paper) }
    association(:invitee, factory: :user)
    association(:actor, factory: :user)
    decision { build(:decision, paper: paper) }

    after(:build) do |invitation, evaluator|
      if evaluator.invitee && invitation.email.nil?
        invitation.email = evaluator.invitee.email
      end
      invitation.body = "You've been invited to"
    end

    # Ensure that these associations are saved if necessary.
    # (We `build` them above)
    after(:create) do |invitation|
      invitation.task.try(:save)
      invitation.decision.try(:save)
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
