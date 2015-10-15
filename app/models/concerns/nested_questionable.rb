module NestedQuestionable
  extend ActiveSupport::Concern

  class_methods do
    def nested_questions
      []
    end
  end

  included do
    has_many :nested_question_answers, as: :owner, dependent: :destroy
  end

  def nested_questions
    self.class.nested_questions
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
    answers = nested_question_answers.includes(:nested_question)
    answers_by_question_id = answers.reduce({}) do |h, answer|
      h[answer.nested_question_id] = answer
      h
    end

    questions = answers.map(&:nested_question).select{ |q| q.parent.blank? }
    path_parts = ident.split(".")
    found_questions = find_nested_questions(path_parts, questions)
    question = found_questions.first

    answers_by_question_id[question.id] if question
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
