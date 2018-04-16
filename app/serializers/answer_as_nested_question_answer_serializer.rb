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

# Sends Answers to the frontend in the same shape as NestedQuestionAnswers
class AnswerAsNestedQuestionAnswerSerializer < AuthzSerializer
  root :nested_question_answer
  attributes :id, :value_type, :value, :owner, :nested_question_id
  has_many :attachments, embed: :ids, include: true, root: :question_attachments

  def owner
    { id: object.owner_id, type: object.owner_type.demodulize }
  end

  def nested_question_id
    object.card_content_id
  end

  def value
    if reviewer_report? && can_see_active_edit?
      additional = object.additional_data || {}
      additional["pending_edit"]
    else
      object.value
    end
  end

  def reviewer_report?
    object.owner.class == ReviewerReport
  end

  def can_see_active_edit?
    object.owner.active_admin_edit? && current_user.can?(:edit_answers, object.owner.paper)
  end
end
