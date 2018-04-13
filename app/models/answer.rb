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

##
# This model will store the answer given to a piece of
# CardContent.
#
class Answer < ActiveRecord::Base
  include ViewableModel
  include Readyable

  belongs_to :card_content
  belongs_to :owner, polymorphic: true
  belongs_to :paper
  belongs_to :repetition, inverse_of: :answers

  has_many :attachments, -> { order('id ASC') },
                              dependent: :destroy,
                              as: :owner,
                              class_name: 'QuestionAttachment'

  validates :card_content, presence: true
  validates :owner, presence: true
  validates :paper, presence: true

  delegate :value_type, :ident, to: :card_content

  before_save :sanitize_html, if: :html_value_type?
  # The 'value: true' option means it's validating value using
  # the value validator.
  # See http://api.rubyonrails.org/classes/ActiveModel/Validator.html
  validates :value, value: true, on: :ready

  delegate_view_permission_to :task

  def children
    Answer.where(owner: owner, card_content: card_content.children)
  end

  # Just like the old NestedQuestionAnswer, the type of the 'value' column
  # in the database is a string, so any values that come out will have to
  # be coerced to the appropriate type before use.
  def string_value
    self[:value]
  end

  # 'value' is the coerced value of the answer, based on the value_type for
  # this answer's card content
  def value
    CoerceAnswerValue.coerce(string_value, value_type)
  end

  # The primary reason an answer will need to find its task is for permission
  # checks in various controllers, since our R&P system normally speaks in
  # Tasks rather than at a more granular level
  def task
    if owner.is_a?(Task)
      owner
    elsif owner.respond_to?(:task)
      owner.task
    else
      raise NotImplementedError, <<-ERROR.strip_heredoc
        The owner (#{owner.inspect}) is not a Task and does not respond to
        #task. This is currently unsupported on #{self.class.name} and if you
        meant it to work you may need to update the implementation.
      ERROR
    end
  end

  def answer_blank?
    if card_content.value_type == 'attachment'
      attachments.empty?
    elsif card_content.content_type == 'check-box'
      value != true
    elsif value.nil?
      true
    elsif value.kind_of?(String)
      value.blank?
    else
      # It's not nil, so I guess it's not blank.
      false
    end
  end

  def question
    card_content.text
  end

  private

  def html_value_type?
    value_type == 'html'
  end

  def sanitize_html
    self[:value] = HtmlScrubber.standalone_scrub!(string_value)
  end
end
