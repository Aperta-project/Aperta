FactoryGirl.define do
  factory :card_content do
    ident { "#{Faker::Lorem.word}--#{Faker::Lorem.word}" }
    value_type "text"
    after(:build) do |c|
      c.card_version = build(:card_version, card_contents: [c]) unless c.card_version.present?
    end

    trait :root do
      parent_id nil
    end

   trait :with_answer do
     transient do
       answer_value nil
     end

     after(:create) do |card_content, evaluator|
       task = Task.find_by(card_version: card_content.card_version)
       FactoryGirl.create(:answer, card_content: card_content, paper: task.try(:paper), owner: task, value: evaluator.answer_value)
     end
   end

    trait :with_child do
      after(:create) do |root_content|
        FactoryGirl.create(:card_content).move_to_child_of(root_content)
        root_content.reload
      end
    end

    trait :with_children do
      after(:create) do |root_content|
        child_count = 0
        5.times do
          child = FactoryGirl.create(:card_content).move_to_child_of(root_content)
          child_count.times do
            FactoryGirl.create(:card_content).move_to_child_of(child)
          end
          child_count += 1
        end
        root_content.reload
      end
    end

    trait :with_string_match_validation do
      after(:build) do |c|
        c.card_version = build(:card_version, card_contents: [c]) unless c.card_version.present?
        c.card_content_validations << build(:card_content_validation, :with_string_match_validation)
      end
    end
  end
end
