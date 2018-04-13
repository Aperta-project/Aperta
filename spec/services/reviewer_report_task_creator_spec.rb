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

require 'rails_helper'

describe ReviewerReportTaskCreator do
  let!(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_task_participant_role,
      :with_reviewer_role,
      :with_reviewer_report_owner_role
    )
  end
  let!(:paper) { FactoryGirl.create(:paper, :submitted, journal: journal) }
  let!(:originating_task) { FactoryGirl.create(:paper_reviewer_task, paper: paper) }
  let!(:assignee) { FactoryGirl.create(:user) }
  let!(:invitation) do
    FactoryGirl.create(
      :invitation,
      :accepted,
      accepted_at: DateTime.now.utc,
      invitee: assignee,
      task: originating_task,
      decision: paper.draft_decision
    )
  end
  subject do
    ReviewerReportTaskCreator.new(
      originating_task: originating_task,
      assignee_id: assignee.id
    )
  end

  before do
    CardLoader.load("ReviewerReport")
    CardLoader.load("TahiStandardTasks::ReviewerReportTask")
    CardLoader.load("TahiStandardTasks::FrontMatterReviewerReport")
    CardLoader.load("TahiStandardTasks::FrontMatterReviewerReportTask")
    FactoryGirl.create :review_duration_period_setting_template
  end

  context "when the paper is configured to use the research reviewer report" do
    before do
      paper.update_column :uses_research_article_reviewer_report, true
      paper.draft_decision.invitations << invitation
    end

    it "sets the task to be a ReviewerReportTask" do
      task = subject.process
      expect(task).to be_kind_of(TahiStandardTasks::ReviewerReportTask)
    end

    it_behaves_like 'creating a reviewer report task', reviewer_report_type: TahiStandardTasks::ReviewerReportTask
  end

  context "when the paper is not configured to use the research reviewer report" do
    before do
      paper.update_column :uses_research_article_reviewer_report, false
    end

    it "sets the task to be a FrontMatterReviewerReportTask" do
      task = subject.process
      expect(task).to be_kind_of(TahiStandardTasks::FrontMatterReviewerReportTask)
    end

    it_behaves_like 'creating a reviewer report task', reviewer_report_type: TahiStandardTasks::FrontMatterReviewerReportTask
  end
end
