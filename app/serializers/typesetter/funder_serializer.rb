module Typesetter
  # Serializes a funder for the typesetter.
  # Expects a funder as its object to serialize.
  class FunderSerializer < Typesetter::TaskAnswerSerializer
    attributes :additional_comments, :name, :grant_number, :website, :influence,
               :influence_description

    def influence
      object.answer_for('funder--had_influence').try(:value)
    end

    def influence_description
      object.answer_for('funder--had_influence--role_description').try(:value)
    end
  end
end
