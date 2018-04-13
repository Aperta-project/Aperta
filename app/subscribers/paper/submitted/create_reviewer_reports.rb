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

# After a resubmission, we need to generate a new
# reviewer report for any existing review tasks
class Paper::Submitted::CreateReviewerReports
  REVIEWER_SPECIFIC_TASKS = ["TahiStandardTasks::FrontMatterReviewerReportTask",
                             "TahiStandardTasks::ReviewerReportTask"].freeze

  def self.call(_, event_data)
    paper = event_data[:record]

    reviewer_tasks = paper.tasks.where(type: REVIEWER_SPECIFIC_TASKS)
    reviewer_tasks.each do |task|
      report = ReviewerReport.find_or_initialize_by(
        task: task,
        decision: paper.draft_decision,
        user: task.reviewer
      )
      report.save!
    end
  end
end
