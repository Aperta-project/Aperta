module Typesetter
  # Serializes competing interests for the typesetter.
  # Expects the competing interests task as its object to serialize.
  class CompetingInterestsSerializer < Typesetter::TaskAnswerSerializer
    attributes :competing_interests, :competing_interests_statement

    def competing_interests
      object.answer_for('competing_interests--has_competing_interests').try(:value)
    end

    def competing_interests_statement
      return no_competing_interests unless competing_interests
      object.answer_for('competing_interests--statement').try(:value)
    end

    def no_competing_interests
      'The authors have declared that no competing interests exist.'
    end
  end
end
