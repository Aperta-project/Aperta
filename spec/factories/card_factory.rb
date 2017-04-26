FactoryGirl.define do
  factory :card do
    sequence(:name) { |n| "Test Card #{n}" }
    journal
    latest_version 1

    trait :versioned do
      after(:build) do |card|
        card.card_versions << build(:card_version, version: card.latest_version, published_at: DateTime.now.utc) if card.card_versions.count.zero?
      end
    end

    trait :archived do
      after(:build) do |card|
        card.archived_at = DateTime.now.utc
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
