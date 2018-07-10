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
require 'support/pages/page'
require 'support/pages/paper_page'
require 'support/pages/paper_workflow_page'
require 'support/pages/tasks/reviewer_report_task_overlay'
require 'support/rich_text_editor_helpers'

include RichTextEditorHelpers

feature 'Reviewer filling out their research article reviewer report', js: true do
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :submitted_lite,
      :with_creator,
      journal: journal,
      uses_research_article_reviewer_report: true
    )
  end
  let(:task) { FactoryGirl.create :paper_reviewer_task, :with_loaded_card, paper: paper }

  let(:paper_page) { PaperPage.new }
  let(:workflow_page) { PaperWorkflowPage.new }
  let!(:reviewer) { create :user }
  let(:journal_admin) { FactoryGirl.create(:user) }

  let!(:inviter) { create :user }

  def create_reviewer_invitation(paper)
    paper.draft_decision.invitations << FactoryGirl.create(
      :invitation,
      :accepted,
      accepted_at: DateTime.now.utc,
      task: task,
      invitee: reviewer,
      inviter: inviter,
      decision: paper.draft_decision
    )
  end

  def create_reviewer_report_task
    ReviewerReportTaskCreator.new(
      originating_task: task,
      assignee_id: reviewer.id
    ).process
  end

  before do
    assign_reviewer_role paper, reviewer
    assign_journal_role(journal, journal_admin, :admin)
    FactoryGirl.create :feature_flag, name: "PREPRINT"
  end

  scenario "A paper's creator cannot access the Reviewer Report" do
    create_reviewer_invitation(paper)
    reviewer_report_task = create_reviewer_report_task

    ensure_user_does_not_have_access_to_task(
      user: paper.creator,
      task: reviewer_report_task
    )
  end

  context 'reviewer is logged in' do
    before do
      login_as(reviewer, scope: :user)
      visit "/"
    end

    scenario 'A reviewer can fill out their own Reviewer Report, submit it, and see a readonly view of their responses' do
      create_reviewer_invitation(paper)
      reviewer_report_task = create_reviewer_report_task
      report = reviewer_report_task.reviewer_reports.first
      expect(report.scheduled_events.pluck(:state).uniq).to eq ['active']

      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", ReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      t.fill_in_report 'reviewer_report--competing_interests--detail' => 'I have no competing interests'
      t.submit_report
      t.confirm_submit_report

      expect(page).to have_selector('.answer-text', text: 'I have no competing interests')
      expect(report.scheduled_events.pluck(:state).uniq).to eq ['canceled']
    end

    scenario 'A review can see their previous rounds of review' do
      # seed the Upload Manuscript card so that it can be created after a decision has been registered
      ctt = CardTaskType.find_by(task_class: "TahiStandardTasks::UploadManuscriptTask")
      FactoryGirl.create(:card, :versioned, card_task_type: ctt)

      create_reviewer_invitation(paper)
      create_reviewer_report_task

      # Revision 0
      Page.view_paper paper

      t = paper_page.view_task("Review by #{reviewer.full_name}", ReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      t.fill_in_report 'reviewer_report--competing_interests--detail' => 'answer for round 0'

      t.submit_report
      t.confirm_submit_report
      # no history yet, since we only have the current round of review
      t.ensure_no_review_history

      # Revision 1
      register_paper_decision(paper, "major_revision")
      paper.tasks.find_by(title: "Upload Manuscript").complete! # a reviewer can't complete this task, so this is a quick workaround
      paper.submit! paper.creator

      create_reviewer_invitation(paper)
      reviewer_report_task = create_reviewer_report_task
      reviewer_report_task.reviewer_reports
        .where(state: 'invitation_not_accepted')
        .first.accept_invitation!

      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", ReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      t.fill_in_report 'reviewer_report--competing_interests--detail' => 'answer for round 1'

      t.submit_report
      t.confirm_submit_report

      t.ensure_review_history(title: 'v0.0', answers: ['answer for round 0'])

      # Revision 2
      register_paper_decision(paper, "major_revision")
      paper.tasks.find_by(title: "Upload Manuscript").complete! # a reviewer can't complete this task, so this is a quick workaround
      paper.submit! paper.creator

      create_reviewer_invitation(paper)
      create_reviewer_report_task

      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", ReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      t.fill_in_report 'reviewer_report--competing_interests--detail' => 'answer for round 2'

      t.ensure_review_history(
        { title: 'v0.0', answers: ['answer for round 0'] },
        title: 'v1.0', answers: ['answer for round 1']
      )

      # Revision 3 (we won't answer, just look at previous rounds)
      register_paper_decision(paper, "major_revision")
      paper.tasks.find_by(title: "Upload Manuscript").complete! # a reviewer can't complete this task, so this is a quick workaround
      paper.submit! paper.creator

      create_reviewer_invitation(paper)
      create_reviewer_report_task

      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", ReviewerReportTaskOverlay)

      t.ensure_review_history(
        { title: 'v0.0', answers: ['answer for round 0'] },
        { title: 'v1.0', answers: ['answer for round 1'] },
        title: 'v2.0', answers: ['answer for round 2']
      )
    end

    scenario 'Rescinded invitations cancel scheduled events' do
      create_reviewer_invitation(paper)
      reviewer_report_task = create_reviewer_report_task
      report = reviewer_report_task.reviewer_reports.first
      expect(report.scheduled_events.pluck(:state).uniq).to eq ['active']
      report.rescind_invitation!
      expect(report.scheduled_events.pluck(:state).uniq).to eq ['canceled']
    end

    scenario 'Changing due dates updates active event dispatch times' do
      create_reviewer_invitation(paper)
      reviewer_report_task = create_reviewer_report_task
      report = reviewer_report_task.reviewer_reports.first
      report.rescind_invitation!
      report.accept_invitation!

      expect(ScheduledEvent.active.count).to eq 3
      expect(ScheduledEvent.canceled.count).to eq 3

      canceled_dates = ScheduledEvent.all.canceled.pluck(:dispatch_at)
      active_dates = ScheduledEvent.all.active.pluck(:dispatch_at)

      report.due_datetime.update!(due_at: report.due_at + 1.day)
      report.schedule_events

      expect(ScheduledEvent.canceled.pluck(:dispatch_at)).to eq canceled_dates
      expect(ScheduledEvent.active.pluck(:dispatch_at)).to_not eq active_dates
    end

    scenario 'Reviewer can upload attachments' do
      create_reviewer_invitation(paper)
      create_reviewer_report_task

      Page.view_paper paper
      paper_page.view_task("Review by #{reviewer.full_name}", ReviewerReportTaskOverlay)

      expect(page).to have_css('.attachment-manager')
      expect(page).to have_content('UPLOAD FILE')

      expect(DownloadAttachmentWorker).to receive(:perform_async)
      file_path = Rails.root.join('spec', 'fixtures', 'about_turtles.docx')
      attach_file 'file', file_path, visible: false

      expect(page).to have_css('.attachment-item')
    end

    scenario 'A journal admin can edit a submitted reviewer report' do
      create_reviewer_invitation(paper)
      reviewer_report_task = create_reviewer_report_task
      reviewer_report_task.reviewer_reports.first
      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", ReviewerReportTaskOverlay)
      wait_for_editors
      t.fill_in_report 'reviewer_report--competing_interests--detail' => 'I have no competing interests'
      t.submit_report
      t.confirm_submit_report

      logout
      login_as(journal_admin, scope: :user)
      workflow_page.view_task(reviewer_report_task)
      find('#edit-reviewer-report').click
      wait_for_editors
      set_rich_text editor: 'reviewer_report--competing_interests--detail', text: 'revert this'
      wait_for_ajax
      click_button("cancel")
      expect(page).to have_selector('.answer-text', text: 'I have no competing interests')

      find('#edit-reviewer-report').click
      wait_for_editors
      set_rich_text editor: 'reviewer_report--competing_interests--detail', text: 'save this'
      find('.required-standalone textarea').set 'Edit notes'
      expect { Answer.first.value }.to become('<p>I have no competing interests</p>')
      page.execute_script("$(\"button:contains('save')\").trigger('click')")
      expect { Answer.first.value }.to become('<p>save this</p>')
      expect(page).to have_selector('.answer-text', text: 'save this')
    end
  end
end
