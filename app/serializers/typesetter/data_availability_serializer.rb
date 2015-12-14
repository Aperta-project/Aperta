module Typesetter
  # Serializes the data availability statement for the typesetter.
  # Expects the data availability task as its object to serialize.
  class DataAvailabilitySerializer < Typesetter::TaskAnswerSerializer
    attributes :data_fully_available, :data_location_statement

    def data_fully_available
      task_answer_value(object, 'data_availability--data_fully_available')
    end

    def data_location_statement
      task_answer_value(object, 'data_availability--data_location')
    end
  end
end
