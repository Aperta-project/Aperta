module Typesetter
  # Serializes the data availability statement for the typesetter.
  # Expects the data availability task as its object to serialize.
  class DataAvailabilitySerializer < Typesetter::TaskAnswerSerializer
    attributes :data_fully_available, :data_location_statement

    def attributes
      super if object
    end

    def data_fully_available
      object.answer_for('data_availability--data_fully_available').try(:value)
    end

    def data_location_statement
      object.answer_for('data_availability--data_location').try(:value)
    end
  end
end
