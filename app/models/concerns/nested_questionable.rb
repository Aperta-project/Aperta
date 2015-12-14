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
  def find_or_build_answer_for(nested_question:, decision: nil)
    nested_question_answers.find_or_build(
      nested_question: nested_question,
      decision: decision
    )
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

  def find_nested_question(ident)
    find_nested_questions(ident.split("."), nested_questions).first
  end

  protected

  # Recursively searches the given +nested_questions+ based on the collection
  # of +path_parts+ provided to find all questions matching the given path_parts.
  #
  # ==== Non-recursive Example
  #
  #   find_nested_questions(["foo"], nested_questions)
  #
  # The above will only search the top-level elements provided in +nested_questions+
  # to see if any has a matching ident of 'foo'.
  #
  # ==== Recursive Example (searching children)
  #
  #   find_nested_questions(["foo", "bar", "baz"], nested_questions)
  #
  # The above will expect to find "baz" nested two levels deep inside of
  # +nested_questions+. It will expect to find "foo" in the top-level, then
  # it will expect to find "bar" in foo's children. Lastly, it will expect to
  # find "baz" in the children of bar.
  #
  def find_nested_questions(path_parts, nested_questions)
    current_ident = path_parts.first
    remaining_path_parts = path_parts[1..-1]
    found_questions = nested_questions.select { |question| question.ident == current_ident }

    if remaining_path_parts.empty?
      found_questions
    else
      find_nested_questions(remaining_path_parts, found_questions.map(&:children).flatten)
    end
  end

end
