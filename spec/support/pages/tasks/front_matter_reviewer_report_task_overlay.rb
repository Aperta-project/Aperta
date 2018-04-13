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

# encoding: utf-8

require_relative 'reviewer_report_task_overlay'
require 'support/rich_text_editor_helpers'

class FrontMatterReviewerReportTaskOverlay < ReviewerReportTaskOverlay
  include RichTextEditorHelpers

  def fill_in_report(values = {})
    values = values.with_indifferent_access.reverse_merge(
      "front_matter_reviewer_report--competing_interests" => "default competing interests content",
      "front_matter_reviewer_report--additional_comments" => "default additional_comments content",
      "front_matter_reviewer_report--identity" => "default identity content"
    )

    fill_in_fields(values)
  end

  def fill_in_fields(values = {})
    wait_for_editors
    values.each_pair do |key, value|
      set_rich_text editor: key, text: value
    end
  end

  def reload(reviewer_report_task=TahiStandardTasks::FrontMatterReviewerReportTask.last)
    paper = reviewer_report_task.paper
    visit "/papers/#{paper.id}/tasks/#{reviewer_report_task.id}"
  end
end
