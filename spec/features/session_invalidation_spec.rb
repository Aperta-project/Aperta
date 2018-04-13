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

require "rails_helper"
require 'support/pages/paper_page'
require 'support/pages/tasks/front_matter_reviewer_report_task_overlay'

feature "session invalidation", js: true do
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_creator,
      :submitted_lite,
      journal: journal,
      uses_research_article_reviewer_report: false
    )
  end
  let(:task) { FactoryGirl.create :paper_reviewer_task, :with_loaded_card, paper: paper }
  let!(:invitation_no_feedback) do
    FactoryGirl.create(
      :invitation,
      :accepted,
      accepted_at: DateTime.now.utc,
      task: task,
      invitee: reviewer,
      inviter: inviter,
      decision: paper.draft_decision
    )
  end
  let(:paper_page) { PaperPage.new }
  let!(:reviewer) { create :user }
  let!(:inviter) { create :user }
  let!(:reviewer_report_task) do
    CardLoader.load("TahiStandardTasks::ReviewerReportTask")
    paper.draft_decision.invitations << invitation_no_feedback
    ReviewerReportTaskCreator.new(
      originating_task: task,
      assignee_id: reviewer.id
    ).process
  end

  before do
    assign_reviewer_role paper, reviewer
    login_as(reviewer, scope: :user)
    Page.view_paper paper
  end

  context "editing a field with an invalid CSRF token" do
    scenario "the user is logged out and returned to the login screen" do
      ident = "front_matter_reviewer_report--competing_interests"
      t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

      # Mess up the CSRF token
      execute_script <<-JS
        $("head meta[name='csrf-token']").attr("content", "bad token")
      JS

      t.fill_in_fields(ident => "Oops, this is the wrong value")

      # Verify that we're looking at the login screen
      find("h1", text: "Welcome to Aperta")
    end
  end
end
