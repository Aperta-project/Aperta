FactoryGirl.define do
  factory :figure do
    association :owner, factory: :paper
  end
end
