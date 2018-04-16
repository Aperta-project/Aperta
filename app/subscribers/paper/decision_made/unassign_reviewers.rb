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

# Rescinds any in-flight reviewer invitations when a decision is made.
# Reviewers are also unassigned from the paper, but that
# process is owned by Paper::DecisionMade::UnassignReviewers
# which lives in the main app.
class Paper::DecisionMade::UnassignReviewers
  REVIEWER_SPECIFIC_TASKS = ["TahiStandardTasks::FrontMatterReviewerReportTask",
                             "TahiStandardTasks::ReviewerReportTask"]

  def self.call(_event_name, event_data)
    paper = event_data[:record]
    invalidate_invitations(paper)
    unassign_reviewers(paper)
  end

  def self.invalidate_invitations(paper)
    invitations = Invitation.joins(:task).where(
      'tasks.paper_id' => paper.id,
      'tasks.type' => 'TahiStandardTasks::PaperReviewerTask',
      'invitations.state' => 'invited')

    invitations.each(&:rescind!)
  end

  def self.unassign_reviewers(paper)
    participant_role = paper.journal.task_participant_role
    reviewer_role = paper.journal.reviewer_role
    reviewer_tasks = paper.tasks.where(type: REVIEWER_SPECIFIC_TASKS)

    paper.reviewers.each do |reviewer|
      reviewer.resign_from!(
        assigned_to: reviewer_tasks,
        role: participant_role
      )
      reviewer.resign_from!(assigned_to: paper, role: reviewer_role)
    end
  end
end
