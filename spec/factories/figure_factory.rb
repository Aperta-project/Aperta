FactoryGirl.define do
  factory :figure, parent: :attachment, class: 'Figure' do
    association :owner, factory: :paper
    status 'done'
    sequence(:title_html) { |n| "Fig. #{n}" }

    transient do
      resource_token_count 1
    end

    after(:create) do |figure, evaluator|
      create_list(
        :resource_token,
        evaluator.resource_token_count,
        owner: figure
      )
    end

    trait :unprocessed do
      status nil
      title_html nil
    end
  end
end
