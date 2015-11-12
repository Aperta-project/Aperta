class NestedQuestionableFactory
  class << self
    def create(owner, questions:)
      @owner = owner
      create_questions(questions)
      @owner
    end

    def create_questions(questions, parent: nil)
      questions.each do |question_hash|
        question = create_question(question_hash, parent)
        create_answer(question_hash, question)
        if question_hash[:questions]
          create_questions(question_hash[:questions], parent: question)
        end
      end
    end

    def create_question(question_hash, parent)
      FactoryGirl.create(
        :nested_question,
        parent: parent,
        text: question_hash[:text],
        ident: question_hash[:ident],
        owner: @owner,
        owner_type: @owner.class.name,
        value_type: question_hash[:value_type]
      )
    end

    def create_answer(question_hash, question)
      FactoryGirl.create(
        :nested_question_answer,
        nested_question: question,
        owner: @owner,
        value: question_hash[:answer],
        value_type: question_hash[:value_type]
      )
    end
  end
end
