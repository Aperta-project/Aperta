FactoryGirl.define do
  factory :withdrawal do
    association :withdrawn_by_user, factory: :user
    paper
    previous_publishing_state 'unsubmitted'
    reason { Faker::Lorem.sentence }
  end
end
