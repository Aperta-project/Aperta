FactoryGirl.define do
  factory :card do
    sequence(:name) { |n| "Test Card #{n}" }
    journal
    latest_version 1
    card_task_type

    trait :versioned do
      after(:build) do |card|
        card.state = "published"
        card.card_versions << FactoryGirl.build(
          :card_version,
          card: card,
          version: card.latest_version,
          published_at: Time.current,
          history_entry: "test version"
        ) if card.card_versions.size.zero?
      end
    end

    # draft is intended to be used with versioned.
    # in our tests it's more common to use published cards,
    # hence draft is a separate trait that acts after :create
    trait :draft do
      after(:create) do |card|
        card.update(state: "draft")
        card.latest_card_version.update(published_at: nil, history_entry: nil)
      end
    end

    trait :locked do
      after(:build) do |card|
        card.state = "locked"
      end
    end

    trait :published_with_changes do
      after(:build) do |card|
        card.state = "published_with_changes"
        card.card_versions << build(:card_version, version: card.latest_version, published_at: Time.current, history_entry: "entry") if card.card_versions.count.zero?
        # TODO: we should probably remove :latest_version from Card all
        # together. currently the XMLCardLoader handles incrementing it, which
        # is just an opportunity to let it get out of sync with the actual
        # latest CardVersion.version.
        card.increment(:latest_version)
        card.card_versions << build(:card_version, version: card.latest_version, published_at: nil)
      end
    end

    trait :archived do
      after(:build) do |card|
        card.state = "archived"
        card.archived_at = Time.current
      end
    end

  end
end
