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

module TahiStandardTasks
  # :nodoc:
  class RegisterDecisionTask < Task
    include UrlBuilder
    DEFAULT_TITLE = 'Register Decision'.freeze
    DEFAULT_ROLE_HINT = 'editor'.freeze

    delegate :letter_templates, to: :journal

    before_save { paper.save! }

    def after_register(decision)
      if decision.revision?
        ReviseTask.setup_new_revision(paper, phase)
        UploadManuscriptTask.setup_new_revision(paper, phase)
        TitleAndAbstractTask.setup_new_revision(paper, phase)
      end
      complete!
    end

    def send_email
      to_field = answer_for(
        'register_decision_questions--to-field'
      ).try(:value)
      subject_field = answer_for(
        'register_decision_questions--subject-field'
      ).try(:value)

      RegisterDecisionMailer.delay.notify_author_email(
        to_field: EmailService.new(email: to_field).valid_email_or_nil,
        subject_field: subject_field,
        decision_id: paper.decisions.completed.last.id
      )
    end
  end
end
