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

# QuestionAttachment is a file attached to an answer for a specific question.
# It will have an owner of Answer.
class QuestionAttachment < Attachment
  include Readyable
  validates :filename, value: true, on: :ready

  self.public_resource = true

  def self.cover_letter
    joins(<<-SQL
  INNER JOIN answers ON answers.id = attachments.owner_id
  INNER JOIN card_contents on card_contents.id = answers.card_content_id
  SQL
         ).where(card_contents: { ident: "cover_letter--attachment" })
  end

  def card_content
    owner.card_content
  end

  def answer_blank?
    filename.nil?
  end

  def user_can_view?(check_user)
    check_user.can?(:view, find_task)
  end

  def find_task # rubocop:disable Metrics/CyclomaticComplexity,Metrics/PerceivedComplexity,Metrics/AbcSize
    @find_task ||= begin
      owner = self
      until owner.is_a? Task
        if owner.respond_to?(:task) && !owner.task.nil?
          owner = owner.task
        elsif owner.respond_to?(:owner) && !owner.owner.nil?
          owner = owner.owner
        elsif owner.respond_to?(:card_content) && !owner.card_content.nil?
          owner = owner.card_content
        elsif owner.respond_to? :answer
          owner = owner.answer
        else
          raise ArgumentError, "Cannot find task for question attachment"
        end
      end
    end
    owner
  end
end
