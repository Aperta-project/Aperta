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
  # Note the ReviewerReportTask and its subclasses are used for
  # "ALL REVIEWS COMPLETE" in the paper tracker. If a task is expected to show
  # up in the "ALL REVIEWS COMPLETE" query, it should inherit from
  # ReviewerReportTask.
  class ReviewerReportTask < Task
    DEFAULT_TITLE = 'Reviewer Report'.freeze
    DEFAULT_ROLE_HINT = 'reviewer'.freeze
    SYSTEM_GENERATED = true

    has_many :reviewer_reports, inverse_of: :task, foreign_key: :task_id

    # Overrides Task#restore_defaults to not restore +title+. This
    # will never update +title+ as that is dynamically determined. If you
    # need to change the reviewer report title write a data migration.
    def self.restore_defaults
    end

    def reviewer_number
      ReviewerNumber.number_for(reviewer, paper)
    end

    def body
      # body is a json column by default which returns an Array. We don't want
      # an array, we want to store properties. So if we get a blank
      # object from the DB then return a Hash instead of the default json Array.
      # Additionally, cache the body so we can set individual properties via
      # calls like "body['foo'] = 'bar'" and have them persist when this
      # task is saved.
      @body ||= begin
        result = super
        result.blank? ? {} : result
      end
    end

    def body=(new_body)
      @body = nil
      super(new_body)
    end

    def can_change?(_)
      !submitted?
    end

    def submitted?
      latest_reviewer_report.submitted?
    end

    # before save we want to update the reviewer number if neccessary
    def on_completion
      super
      return unless persisted? # don't assign reviewer numbers to newly created tasks
      assign_reviewer_number if completed?
    end

    def assign_reviewer_number
      return if reviewer_number.present? || !paper.number_reviewer_reports
      add_number_to_title(new_reviewer_number)
    end

    def new_reviewer_number
      ReviewerNumber.assign_new(reviewer, paper)
    end

    # this is meant to run in a `before_save` hook so don't
    # call `save` in the method body
    def add_number_to_title(new_number)
      new_title = title + " (##{new_number})"
      self.title = new_title
    end

    def latest_reviewer_report
      reviewer_reports.order('created_at DESC').first
    end

    def display_status
      latest_reviewer_report.display_status
    end
  end
end
