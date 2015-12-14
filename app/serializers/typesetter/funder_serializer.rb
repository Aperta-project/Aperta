module Typesetter
  # Serializes a funder for the typesetter.
  # Expects a funder as its object to serialize.
  class FunderSerializer < Typesetter::TaskAnswerSerializer
    attributes :name, :grant_number, :website, :influence,
               :influence_description

    def influence
      task_answer_value(object, 'funder--had_influence')
    end

    def influence_description
      task_answer_value(object, 'funder--had_influence--role_description')
    end
  end
end
