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
    #prevent from failing before upload finished and on parent answer
    return true if attachment.kind_of?(Answer) || !attachment.title
    check_string_match(validator, attachment.filename)
  end

  def check_string_match(validator, target)
    regex = Regexp.new(validator)
    (target =~ regex).present?
  end
end
