module NestedQuestionable
  extend ActiveSupport::Concern

  class_methods do
    def nested_questions
      NestedQuestion.where(owner_id: nil, owner_type: name)
    end
  end

  included do
    has_many :nested_question_answers, as: :owner, dependent: :destroy
  end

  def nested_questions
    self.class.nested_questions
  end

  # find_or_build_answer_for(...) will return the associated answer for this
  # task given the :nested_question parameter.
  #
  # == Optional Parameters
  #  * decision - if provided, will scope the answer to the given :decision.
  #
  def find_or_build_answer_for(nested_question:, decision: nil, value: nil)
    answer = nested_question_answers.find_or_build(
      nested_question: nested_question,
      decision: decision,
      value: value
    )
    answer.paper = paper if respond_to?(:paper)

    answer
  end

  # Returns the answer for a given +ident+ path.
  #
  # ==== Example for a non nested question
  #
  #   answer_for("foo")
  #
  # ==== Example for a nested question
  #
  #   answer_for("foo.bar")
  #
  def answer_for(ident)
    nested_question_answers.includes(:nested_question).find_by(nested_questions: { ident: ident } )
  end

end
