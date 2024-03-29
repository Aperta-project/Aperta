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
require 'support/pages/dashboard_page'
require 'support/pages/overlays/register_decision_overlay'
require 'support/rich_text_editor_helpers'

include RichTextEditorHelpers

feature "Register Decision", js: true, sidekiq: :inline! do
  let(:user) { FactoryGirl.create(:user) }
  let!(:journal) { FactoryGirl.create(:journal_for_integration_tests) }
  let!(:letter_template) { FactoryGirl.create(:letter_template, :notify_submission, journal: journal) }
  let!(:letter_template2) { FactoryGirl.create(:letter_template, :notify_initial_submission, journal: journal) }
  let(:paper) do
    FactoryGirl.create(:paper, :submitted, journal: journal)
  end
  let(:task) { FactoryGirl.create(:register_decision_task, :with_loaded_card, paper: paper) }
  let(:dashboard_page) { DashboardPage.new }
  let(:manuscript_page) { dashboard_page.view_submitted_paper paper }
  let(:accept_template) { FactoryGirl.create(:letter_template, :accept) }
  let(:reject_template) { FactoryGirl.create(:letter_template, :reject) }

  before do
    allow(PlosBilling::SalesforceManuscriptUpdateWorker)
      .to receive(:perform_async).and_return(true)
    task.add_participant(user)
    paper.journal.letter_templates << accept_template
    paper.journal.letter_templates << reject_template
    assign_journal_role paper.journal, user, :editor
    login_as(user, scope: :user)
    visit "/"
  end

  context "Registering a decision on a paper" do
    context "with a submitted Paper" do

      scenario "Disable inputs upon card completion" do
        overlay = Page.view_task_overlay(paper, task)
        overlay.register_decision = "Accept"
        wait_for_editors
        overlay.decision_letter = "Accepting this because I can"
        sleep 1 # letter saves on a debounce
        overlay.click_send_email_button
        wait_for_ajax
        expect(task.reload.completed?).to be true
        expect(overlay).to have_success_state_message
      end

      scenario "persist the decision radio button" do
        overlay = Page.view_task_overlay(paper, task)

        overlay.register_decision = "Reject"
        overlay.radio_selected?
        wait_for_ajax
        visit current_path # Revisit
        expect(overlay).to have_css("input:checked[value='reject']")
      end

      scenario "displays correct letter templates" do
        overlay = Page.view_task_overlay(paper, task)
        wait_for_ajax
        overlay.register_decision = "Reject"
        execute_script("$('.letter-select2 > .select2-container').select2('open');")
        expect(overlay).to have_content(reject_template.name)
        expect(overlay).not_to have_content(accept_template.name)
      end

      context "With assigned and invited reviewers" do
        let(:reviewer_task) do
          FactoryGirl.create :paper_reviewer_task, :with_loaded_card, paper: paper
        end
        let!(:invitation) do
          FactoryGirl.create(:invitation, :invited, task: reviewer_task)
        end
        let!(:assigned_reviewer) { create :user }

        before do
          assign_reviewer_role paper, assigned_reviewer
        end

        scenario "Remove assigned and invited reviewers" do
          expect(
            reviewer_task.invitations
            .where(state: "invited")
            .count
          ).to eq(1)
          expect(paper.reviewers.count).to eq(1)

          overlay = Page.view_task_overlay(paper, task)
          overlay.register_decision = "Accept"
          wait_for_editors
          overlay.decision_letter = "Accepting this because I can"
          sleep 1 # letter saves on a debounce
          overlay.click_send_email_button
          wait_for_ajax

          reviewer_task.reload
          expect(
            reviewer_task.invitations
            .where(state: "invited")
            .count
          ).to eq(0)
          expect(paper.reviewers.count).to eq(0)
        end
      end
    end
  end

  context "With previous decision history" do
    let(:letter) { Faker::Lorem.paragraph(3) }
    before do
      paper.draft_decision.update!(letter: letter)
      register_paper_decision(paper, 'accept')
    end

    scenario "User checks previous decision history" do
      overlay = Page.view_task_overlay(paper, task)
      expect(overlay.previous_decisions).to_not be_empty
      expect(overlay.previous_decisions.first.revision_number).to eq("0.0")
      overlay.previous_decisions.first.open
      expect(overlay.previous_decisions.first.letter)
        .to eq(letter)
      expect(overlay.previous_decisions.first.letter).to_not include "<br>"
    end
  end

  context "with an unsubmitted Paper" do
    before do
      paper.update!(publishing_state: 'unsubmitted')
      paper.reload
    end

    scenario "Participant cannot register a decision on the paper" do
      overlay = Page.view_task_overlay(paper, task)
      expect(overlay.invalid_state_message).to be true
      expect(overlay).to have_content("A decision cannot be registered at this time")
    end
  end

  context "when rescinding a decision" do
    before do
      paper.draft_decision.update!(
        letter: Faker::Lorem.paragraph(3))
      register_paper_decision(paper, 'accept')
      paper.reload
    end

    scenario "user rescinds a decision" do
      overlay = Page.view_task_overlay(paper, task)
      overlay.mark_as_incomplete
      wait_for_ajax
      expect(overlay.rescind_button).to_not be_disabled
      overlay.rescind_button.click
      overlay.rescind_confirm_button.click
      expect(overlay.previous_decisions.first.revision_number).to eq("0.0")
      expect(overlay.previous_decisions.first.rescinded?).to be(true)
    end
  end
end
