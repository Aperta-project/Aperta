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
    check_string_match(validator, answer.value)
  end

  def validate_by_file_name(attachment)
    # prevent from failing before upload finished and on parent answer
    return true if attachment.kind_of?(Answer) || !attachment.title
    check_string_match(validator, attachment.filename)
  end

  def check_string_match(validator, string)
    regex = Regexp.new(validator)
    (string =~ regex).present?
  end

  def validate_by_string_length_minimum(answer)
    return false unless validator =~ /^[0-9]+$/
    answer.value.length >= validator.to_i
  end

  def validate_by_string_length_maximum(answer)
    return false unless validator =~ /^[0-9]+$/
    answer.value.length <= validator.to_i
  end
end
