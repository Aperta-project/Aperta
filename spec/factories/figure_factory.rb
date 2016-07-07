FactoryGirl.define do
  factory :figure, parent: :attachment, class: 'Figure' do
    association :owner, factory: :paper

    trait :with_resource_token do
      after :build, &:create_resource_token!
    end
  end
end
