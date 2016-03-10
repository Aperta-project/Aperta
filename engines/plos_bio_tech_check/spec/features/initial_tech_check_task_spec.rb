require 'rails_helper'

feature 'Initial Tech Check', js: true do
  let(:journal) { create :journal, :with_roles_and_permissions }
  let(:admin) { create :user, site_admin: true }
  let(:author) { create :user }
  let(:paper) { create :paper, :submitted, journal: journal, creator: author }
  let(:task) { create :initial_tech_check_task, paper: paper }

  before do
    assign_journal_role journal, admin, :admin
  end

  scenario 'Initial Tech Check triggers Changes For Author' do
    SignInPage.visit.sign_in admin
    overlay = Page.view_task_overlay(paper, task)
    visit "/papers/#{paper.id}/tasks/#{task.id}"
    expect(PlosBioTechCheck::ChangesForAuthorTask.count).to eq(0)
    overlay.create_author_changes_card
    overlay.expect_author_chages_saved
    overlay.mark_as_complete
    overlay.expect_task_to_be_completed
    overlay.dismiss
    Page.new.sign_out

    change_author_task = PlosBioTechCheck::ChangesForAuthorTask.first

    SignInPage.visit.sign_in author
    overlay = Page.view_task_overlay(paper, change_author_task)
    overlay.expect_to_see_change_list
    overlay.click_changes_have_been_made
    overlay.dismiss

    # creator cannot access iniital tech task
    visit "/papers/#{paper.id}/tasks/#{task.id}"
    expect(page).to have_content("You don't have access to that content")
    Page.new.sign_out
  end

  scenario "list the unselected question items in the author changes letter" do
    SignInPage.visit.sign_in admin
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
    SignInPage.visit.sign_in admin
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
    SignInPage.visit.sign_in admin
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
