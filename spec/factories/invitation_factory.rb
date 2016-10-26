FactoryGirl.define do
  factory :invitation do
    invitee_role 'Some Role'
    email "email@example.com"
    token { SecureRandom.hex(10) }
    paper { create(:paper) }
    task { create(:invitable_task, paper: paper) }
    association(:invitee, factory: :user)
    association(:actor, factory: :user)
    decision { paper.draft_decision || paper.new_draft_decision! }
    invitation_queue { create(:invitation_queue, task: task) }
    body "You've been invited to"

    after(:build) do |invitation, evaluator|
      invitation.email = evaluator.invitee.email if evaluator.invitee
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

    trait :declined do
      state "declined"
    end
  end
end
