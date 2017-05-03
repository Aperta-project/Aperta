FactoryGirl.define do
  factory :card do
    sequence(:name) { |n| "Test Card #{n}" }
    journal
    latest_version 1

    trait :versioned do
      after(:build) do |card|
        card.state = "published"
        card.card_versions << build(:card_version, version: card.latest_version, published_at: Time.current) if card.card_versions.count.zero?
      end
    end

    # draft is intended to be used with versioned.
    # in our tests it's more common to use published cards,
    # hence draft is a separate trait that acts after :create
    trait :draft do
      after(:create) do |card|
        card.update(state: "draft")
        card.latest_card_version.update(published_at: nil)
      end
    end
    trait :archived do
      after(:build) do |card|
        card.state = "archived"
        card.archived_at = Time.current
      end
    end

    trait :for_answerable do
      transient do
        answerable TahiStandardTasks::PublishingRelatedQuestionsTask
        idents 'publishing_related_questions--short_title'
      end

      after(:create) do |card, evaluator|
        idents = Array(evaluator.idents)
        root = create(:card_content, card: card, content_type: "display-children")
        idents.each do |ident|
          create(:card_content, parent: root, card: card, ident: ident)
        end
        evaluator.answerable.update(card: card)
      end
    end
  end
end
