module Typesetter
  # Serializes competing interests for the typesetter.
  # Expects the competing interests task as its object to serialize.
  class CompetingInterestsSerializer < Typesetter::TaskAnswerSerializer
    attributes :competing_interests, :competing_interests_statement

    def competing_interests
      task_answer_value(object, 'competing_interests.has_competing_interests')
    end

    def competing_interests_statement
      return no_competing_interests unless competing_interests
      task_answer_value(object, 'competing_interests.statement')
    end

    def no_competing_interests
      'The authors have declared that no competing interests exist.'
    end
  end
end
