FactoryGirl.define do
  factory :activity do
    association :actor, factory: :user
    association :scope, factory: :paper
    region_name "paper"
    event_name "paper::revised"
    after(:build) do |activity, _|
      activity.target = activity.scope
    end
  end
end
