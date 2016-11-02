module Typesetter
  # Serializes the early posting data for the typesetter.
  # Expects the early posting task as its object to serialize.
  class EarlyPostingSerializer < Typesetter::TaskAnswerSerializer
    attributes :data_fully_available, :data_location_statement

    def data_fully_available
      object.answer_for('data_availability--data_fully_available').try(:value)
    end

    def data_location_statement
      object.answer_for('data_availability--data_location').try(:value)
    end
  end
end
