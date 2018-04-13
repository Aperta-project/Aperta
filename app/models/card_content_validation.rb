# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# This class handles concerns about validations of Answers tied to
# Card Content
class CardContentValidation < ActiveRecord::Base
  include ViewableModel
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
    string_to_validate(answer).length >= validator.to_i
  end

  def validate_by_string_length_maximum(answer)
    return false unless validator =~ /^[0-9]+$/
    string_to_validate(answer).length <= validator.to_i
  end

  def string_to_validate(answer)
    if answer.value_type == 'html'
      ActionView::Base.full_sanitizer.sanitize(answer.value)
    elsif answer.value.nil?
      ""
    else
      answer.value
    end
  end

  def validate_by_required_field(answer)
    !answer.answer_blank?
  end
end
