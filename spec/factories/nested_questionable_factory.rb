class NestedQuestionableFactory
  class << self
    def create(owner, questions:)
      @owner = owner
      build_questions(questions)
      @owner
    end

    def build_questions(questions, parent: nil)
      questions.each do |question_hash|
        question = build_question(question_hash, parent)
        build_answer(question_hash, question)
        if question_hash[:questions]
          build_questions(question_hash[:questions], parent: question)
        end
      end
    end

    def build_question(question_hash, parent)
      FactoryGirl.create(
        :nested_question,
        parent: parent,
        ident: question_hash[:ident],
        owner: @owner,
        value_type: question_hash[:value_type]
      )
    end

    def build_answer(question_hash, question)
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
