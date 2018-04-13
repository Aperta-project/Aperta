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

class ReviewerReportContext < TemplateContext
  include ActionView::Helpers::SanitizeHelper

  whitelist :state, :revision, :status, :datetime, :invitation_accepted?, :due_at
  subcontext  :reviewer, type: :user, source: [:object, :user]
  subcontexts :answers,  type: :answer

  def reviewer_number
    object.task.reviewer_number
  end

  def reviewer_name
    strip_tags(answers.detect { |a| a.ident.ends_with?('--identity') }.try(:value))
  end

  def due_at
    object.due_at.to_s(:due_with_hours)
  end

  def due_at_with_minutes
    object.due_at.to_s(:due_with_minutes)
  end

  def rendered_answer_idents
    [
      'front_matter_reviewer_report--suitable--comment',
      'front_matter_reviewer_report--includes_unpublished_data--explanation',
      'reviewer_report--comments_for_author'
    ]
  end

  def rendered_answers
    rendered_answer_idents.map { |ident| answers.find { |answer| answer.ident == ident } }
      .compact
  end
end
