# coding: utf-8
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

# coding: utf-8

require 'support/rich_text_editor_helpers'
require 'support/pages/fragments/paper_task_overlay'

# Helper class for running specs
# coding: utf-8
class ReviewerReportTaskOverlay < PaperTaskOverlay
  include RichTextEditorHelpers

  def ensure_no_review_history
    expect(page).to_not have_selector(".review-history")
  end

  # Ensures given review(s) is on the page.
  #
  # === Example 1
  #   ensure_review_history(title: "Revision 0",
  #                         answers: ["answer for round 0"])
  #
  # === Example 2
  #   ensure_review_history(
  #     {title: "Revision 0", answers: ["answer for round 0"]},
  #     {title: "Revision 1", answers: ["answer for round 1"]},
  #   )
  def ensure_review_history(*expected_reviews)
    expected_reviews = expected_reviews.flatten
    within ".review-history" do
      expected_reviews.each do |hsh|
        title = hsh[:title]
        expect(page).to have_link(title)

        click_on(title)
        execute_script(%{$(".paper-sidebar").prop("scrollTop", 0).trigger('scroll')})
        hsh[:answers].each do |answer_text|
          expect(page).to have_selector(".answer-text", text: answer_text)
        end
      end
    end
  end

  def fill_in_report(values = {})
    values = values.with_indifferent_access.reverse_merge(
      "reviewer_report--competing_interests--detail" => "default competing interests",
      "reviewer_report--additional_comments" => "default additional_comments content",
      "reviewer_report--identity" => "default identity content"
    )

    fill_in_fields(values)
  end

  def fill_in_fields(values = {})
    wait_for_editors
    values.each_pair do |key, value|
      set_rich_text editor: key, text: value
    end
  end

  def submit_report
    click_button "Submit this Report"
  end

  def confirm_submit_report
    click_button "Yes, I’m sure"
  end

  def reload(reviewer_report_task = TahiStandardTasks::ReviewerReportTask.last)
    paper = reviewer_report_task.paper
    visit "/papers/#{paper.id}/tasks/#{reviewer_report_task.id}"
  end
end
