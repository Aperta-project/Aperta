FactoryGirl.define do
  factory :card do
    name "Test Card"

    trait :for_answerable do
      transient do
        answerable Author
      end

      name { answerable.name }

      after(:create) do |card, evaluator|
        idents = evaluator.answerable::CARD_CONTENT_IDENTS
        root = create(:card_content, card: card)
        idents.each do |ident|
          create(:card_content, parent: root, card: card, ident: ident)
        end
      end
    end
  end
end
