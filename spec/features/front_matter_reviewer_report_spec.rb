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
require 'support/pages/paper_page'
require 'support/pages/tasks/front_matter_reviewer_report_task_overlay'
require 'support/rich_text_editor_helpers'

include RichTextEditorHelpers

feature 'Reviewer filling out their front matter article reviewer report', js: true do
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
  let(:paper_page) { PaperPage.new }
  let!(:reviewer) { create :user }

  let!(:inviter) { create :user }

  def create_reviewer_invitation(paper)
    invitation = FactoryGirl.create(
      :invitation,
      :accepted,
      accepted_at: DateTime.now.utc,
      invitee: reviewer,
      inviter: inviter,
      task: task,
      decision: paper.draft_decision
    )
    paper.draft_decision.invitations << invitation
    invitation
  end

  def create_reviewer_report_task
    ReviewerReportTaskCreator.new(
      originating_task: task,
      assignee_id: reviewer.id
    ).process
  end

  before do
    assign_reviewer_role paper, reviewer
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
      create_reviewer_report_task

      ident = 'front_matter_reviewer_report--competing_interests'

      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      answers = CardContent.find_by(ident: ident).answers
      sentinel_proc = -> { answers.count }

      # Recreating the error in APERTA-8647
      t.wait_for_sentinel(sentinel_proc) do
        t.fill_in_report ident => 'Oops, this is the wrong value'
      end
      t.wait_for_sentinel(sentinel_proc) do
        t.fill_in_report ident => ''
      end
      no_compete = 'I have no competing interests with this work.'
      t.wait_for_sentinel(sentinel_proc) do
        t.fill_in_report ident => no_compete
      end

      t.submit_report
      t.confirm_submit_report

      expect(page).to have_selector(".answer-text", text: no_compete)
      expect(answers.count).to eq(1)
      expect(answers.reload.first.value).to eq('<p>I have no competing interests with this work.</p>')
    end

    scenario 'All answers that should be rendered in a decision letter are rendered' do
      create_reviewer_invitation(paper)
      create_reviewer_report_task

      # seed the Upload Manuscript card so that it can be created after a decision has been registered
      ctt = CardTaskType.find_by(task_class: "TahiStandardTasks::UploadManuscriptTask")
      FactoryGirl.create(:card, :versioned, card_task_type: ctt)

      # Revision 0
      Page.view_paper paper

      t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      t.fill_in_report("front_matter_reviewer_report--suitable--comment" => "test",
                       "front_matter_reviewer_report--includes_unpublished_data--explanation" => "test")

      # no history yet, since we only have the current round of review
      t.ensure_no_review_history

      t.submit_report
      t.confirm_submit_report

      register_paper_decision(paper, "minor_revision")
      answers = ReviewerReport.first.answers
      idents = ReviewerReportContext.new(answers.first).rendered_answer_idents
                 .select { |i| i.match(/front_matter/) }

      expect(idents.length).to eq(2)
      idents.each do |i|
        answer = answers.select { |a| a.card_content.ident == i }.first
        expect(answer.value).to eq('<p>test</p>')
      end
    end

    xscenario 'A reviewer can see their previous rounds of review' do
      create_reviewer_invitation(paper)
      create_reviewer_report_task

      # seed the Upload Manuscript card so that it can be created after a decision has been registered
      ctt = CardTaskType.find_by(task_class: "TahiStandardTasks::UploadManuscriptTask")
      FactoryGirl.create(:card, :versioned, card_task_type: ctt)

      # Revision 0
      Page.view_paper paper

      t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 0'

      # no history yet, since we only have the current round of review
      t.ensure_no_review_history

      t.submit_report
      t.confirm_submit_report

      # Revision 1
      register_paper_decision(paper, "minor_revision")
      paper.tasks.find_by(title: "Upload Manuscript").complete! # a reviewer can't complete this task, so this is a quick workaround
      paper.submit! paper.creator

      # Create new report with our reviewer
      create_reviewer_invitation(paper)
      reviewer_report_task = create_reviewer_report_task
      reviewer_report_task.latest_reviewer_report.accept_invitation!

      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 1'

      t.submit_report
      t.confirm_submit_report

      t.ensure_review_history(
        title: 'v0.0', answers: ['answer for round 0']
      )

      # Revision 2
      register_paper_decision(paper, "minor_revision")
      paper.tasks.find_by(title: "Upload Manuscript").complete! # a reviewer can't complete this task, so this is a quick workaround
      paper.submit! paper.creator

      # Create new report with our reviewer
      create_reviewer_invitation(paper)
      reviewer_report_task = create_reviewer_report_task
      reviewer_report_task.latest_reviewer_report.accept_invitation!

      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

      wait_for_editors # Wait for rich-text editors to instantiate

      t.fill_in_report 'front_matter_reviewer_report--competing_interests' => 'answer for round 2'

      t.ensure_review_history(
        { title: 'v0.0', answers: ['answer for round 0'] },
        title: 'v1.0', answers: ['answer for round 1']
      )

      # Revision 3 (we won't answer, just look at previous rounds)
      register_paper_decision(paper, "minor_revision")
      paper.tasks.find_by(title: "Upload Manuscript").complete! # a reviewer can't complete this task, so this is a quick workaround
      paper.submit! paper.creator

      Page.view_paper paper
      t = paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

      t.ensure_review_history(
        { title: 'v0.0', answers: ['answer for round 0'] },
        { title: 'v1.0', answers: ['answer for round 1'] },
        title: 'v2.0', answers: ['answer for round 2']
      )
    end

    scenario 'Reviewer can upload attachments' do
      create_reviewer_invitation(paper)
      create_reviewer_report_task

      Page.view_paper paper
      paper_page.view_task("Review by #{reviewer.full_name}", FrontMatterReviewerReportTaskOverlay)

      expect(page).to have_css('.attachment-manager')
      expect(page).to have_content('UPLOAD FILE')

      expect(DownloadAttachmentWorker).to receive(:perform_async)
      file_path = Rails.root.join('spec', 'fixtures', 'about_turtles.docx')
      attach_file 'file', file_path, visible: false

      expect(page).to have_css('.attachment-item')
    end
  end
end
