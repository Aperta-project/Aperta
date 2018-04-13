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

class RegisterDecisionScenario < TemplateContext
  wraps Paper
  subcontext  :journal
  subcontext  :manuscript, type: :paper, source: :object
  subcontexts :reviews,    type: :reviewer_report

  def reviews
    @reviews ||= [].tap do |reviews|
      return [] unless object.draft_decision
      reports = object.draft_decision.reviewer_reports.submitted
      reports_with_num, reports_without_num = reports.partition { |r| r.task.reviewer_number }
      reports = reports_with_num.sort_by { |r| r.task.reviewer_number } + reports_without_num.sort_by(&:submitted_at)
      reports.each { |rr| reviews << ReviewerReportContext.new(rr) }
    end
  end
end
