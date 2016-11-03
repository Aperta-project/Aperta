module Typesetter
  # Serializes the early posting data for the typesetter.
  # Expects the early posting task as its object to serialize.
  class EarlyPostingSerializer < Typesetter::TaskAnswerSerializer
    attributes :consent

    def consent
      object.answer_for('early-posting--consent').try(:value)
    end
  end
end
