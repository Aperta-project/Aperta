require 'rails_helper'

feature 'Initial Tech Check', js: true do
  let(:journal) { create :journal }
  let(:admin) { create :user, site_admin: true }
  let(:author) { create :user }
  let(:paper) { create :paper, :submitted, journal: journal, creator: author }
  let(:task) { create :initial_tech_check_task, paper: paper }
  let(:dashboard) { DashboardPage.new }
  let(:manuscript_page) { dashboard.view_submitted_paper paper }

  before do
    assign_journal_role journal, admin, :admin
    task.add_participant(admin)

    SignInPage.visit.sign_in admin
  end

  pending 'Initial Tech Check starts with round 1' do
    manuscript_page = dashboard.view_submitted_paper paper
    overlay = Page.view_task_overlay(paper, task)
    expect(overlay.current_round).to eq 1
    overlay.create_author_changes_card
    overlay.mark_as_complete

    manuscript_page.sign_out
    SignInPage.visit.sign_in author

    manuscript_page = dashboard.view_submitted_paper paper
    overlay = Page.view_task_overlay(paper, task)
    overlay.mark_as_complete

    manuscript_page.submit.submit
    manuscript_page.sign_out
    SignInPage.visit.sign_in admin
    manuscript_page = dashboard.view_submitted_paper paper
    overlay = Page.view_task_overlay(paper, task)
    expect(overlay.current_round).to eq 2
  end

  scenario "list the unselected question items in the author changes letter" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.display_letter
    overlay.click_autogenerate_email_button
    textarea = overlay.letter
    expect(textarea.value).to include "Title, Authors, Affiliations, Abstract, Introduction, Results, Discussion, Materials and Methods, References"

    question_elements = all(".question-checkbox")
    first_question = question_elements.first
    last_question = question_elements.last
    first_question.find("input").click
    last_question.find("input").click

    textarea = overlay.letter
    expect(textarea.value).to_not include first_question.find(".model-question").text
    expect(textarea.value).to_not include last_question.find(".model-question").text
  end

  scenario "selected questions don't show up in the auto-generated author change letter" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.display_letter
    overlay.click_autogenerate_email_button
    textarea = overlay.letter
    expect(textarea.value).to include "Title, Authors, Affiliations, Abstract, Introduction, Results, Discussion, Materials and Methods, References"

    question_elements = all(".question-checkbox")
    first_question = question_elements.first
    first_question.find("input").click
    overlay.click_autogenerate_email_button

    textarea = overlay.letter
    expect(textarea.value).to_not include "Title, Authors, Affiliations, Abstract, Introduction, Results, Discussion, Materials and Methods, References"
  end

  scenario "unchecking a box with no associated text has no effect" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.display_letter
    overlay.click_autogenerate_email_button
    textarea_before = overlay.letter

    question_elements = all(".question-checkbox")
    question = question_elements[1]
    question.find("input").click
    overlay.click_autogenerate_email_button

    textarea_after = overlay.letter
    expect(textarea_before.value).to eq(textarea_after.value)
  end
end
