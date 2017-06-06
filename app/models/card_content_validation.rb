# This class handles concerns about validations of Answers tied to
# Card Content
class CardContentValidation < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :card_content

  def validate_answer(answer)
    send("validate_by_#{validation_type.underscore}", answer)
  end

  private

  def validate_by_string_match(answer)
    regex = Regexp.new(validator)
    result = answer.value =~ regex
    result.present?
  end

  def validate_by_string_length_minimum(answer)
    return false if validator !~ /^[0-9]+$/
    answer.value.length >= validator.to_i
  end

  def validate_by_string_length_maximum(answer)
    return false if validator !~ /^[0-9]+$/
    answer.value.length <= validator.to_i
  end
end
