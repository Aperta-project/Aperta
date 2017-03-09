# Convenience factory for creating CardContent with answers
class AnswerableFactory
  class << self
    def create(owner, questions:)
      card_name = owner.class.name
      card = Card.find_by(name: card_name) ||
        FactoryGirl.create(:card, :versioned, name: card_name)
      create_questions(questions, owner: owner, card: card, parent: card.content_root_for_version(:latest))
      owner
    end

    def create_questions(questions, parent: nil, owner: nil, card: nil)
      questions.each do |question_hash|
        question = create_question(question_hash, parent, owner, card)
        create_answer(question_hash, question, owner)
        next unless question_hash[:questions]
        create_questions(
          question_hash[:questions],
          parent: question,
          owner: owner
        )
      end
    end

    def create_question(question_hash, parent, owner, card)
      card_content = CardContent.find_by(ident: question_hash[:ident]) ||
        FactoryGirl.build(:card_content)

      card_content.tap do |nq|
        nq.parent = parent
        nq.card = card
        nq.text = question_hash[:text]
        nq.ident = question_hash[:ident]
        nq.value_type = question_hash[:value_type]
        nq.save!
      end
    end

    def create_answer(question_hash, question, owner)
      FactoryGirl.create(
        :answer,
        card_content: question,
        owner: owner,
        value: question_hash[:answer]
      )
    end
  end
end
