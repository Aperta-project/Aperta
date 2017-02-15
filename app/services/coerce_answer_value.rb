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
    "boolean" => ->(v) { v.match(TRUTHY_VALUES_RGX) ? true : false },
    default: ->(v) { v }
  }.freeze

  def self.coerce(value, value_type)
    raise ArgumentError unless EXPECTED_VALUE_TYPES.include?(value_type)
    return nil if value.nil?

    coercion = COERCIONS[value_type] || COERCIONS[:default]
    coercion.call(value)
  end
end
