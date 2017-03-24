# Class to coerce string valued answers in the `Answer` class into appropriate
# types, namely booleans (and possibly others in the future)
class CoerceAnswerValue
  TRUTHY_VALUES_RGX = /^(t|true|y|yes|1)/i

  EXPECTED_VALUE_TYPES = [
    "attachment",
    "boolean",
    "text",
    "question_set"
  ].freeze

  COERCIONS = {
    "boolean" => ->(v) { v.match(TRUTHY_VALUES_RGX) ? true : false }
  }.freeze

  IDENTITY = ->(v) { v }

  def self.coerce(value, value_type)
    unless EXPECTED_VALUE_TYPES.include?(value_type)
      msg = "value_type: #{value_type || "<blank value type>"} was not expected"
      raise ArgumentError, msg
    end
    # we need to distinguish between nil? and blank? here, hence the explicit
    # check
    return nil if value.nil?

    COERCIONS.fetch(value_type, IDENTITY).call(value)
  end
end
