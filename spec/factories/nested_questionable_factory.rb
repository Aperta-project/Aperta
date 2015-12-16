class NestedQuestionableFactory
  class << self
    def create(owner, questions:)
      create_questions(questions, owner: owner)
      owner
    end

    def create_questions(questions, parent: nil, owner: nil)
      questions.each do |question_hash|
        question = create_question(question_hash, parent, owner)
        create_answer(question_hash, question, owner)
        if question_hash[:questions]
          create_questions(
            question_hash[:questions],
            parent: question,
            owner: owner)
        end
      end
    end

    def create_question(question_hash, parent, owner)
      nested_question = NestedQuestion.find_by(ident: question_hash[:ident]) ||
        FactoryGirl.build(:nested_question)

      nested_question.tap do |nq|
        nq.parent = parent
        nq.text = question_hash[:text]
        nq.ident = question_hash[:ident]
        nq.owner = owner
        nq.owner_type = owner.class.name
        nq.value_type = question_hash[:value_type]
        nq.save!
      end
    end

    def create_answer(question_hash, question, owner)
      FactoryGirl.create(
        :nested_question_answer,
        nested_question: question,
        owner: owner,
        value: question_hash[:answer],
        value_type: question_hash[:value_type]
      )
    end
  end
end
