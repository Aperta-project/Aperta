require 'rails_helper'

feature 'Initial Tech Check', js: true do
  let(:journal) { create :journal, :with_roles_and_permissions }
  let(:editor) { create :user }
  let(:author) { create :user }
  let(:paper) { create :paper, :checking, journal: journal, creator: author }
  let(:task) { create :initial_tech_check_task, paper: paper }

  before do
    assign_journal_role journal, editor, :editor
  end

  scenario 'Initial Tech Check triggers Changes For Author' do
    # Editor
    login_as(editor, scope: :user)
    overlay = Page.view_task_overlay(paper, task)
    expect(PlosBioTechCheck::ChangesForAuthorTask.count).to eq(0)
    overlay.create_author_changes_card
    wait_for_ajax
    overlay.expect_author_changes_saved
    overlay.mark_as_complete
    overlay.expect_task_to_be_completed
    overlay.dismiss
    Warden.test_reset!

    change_author_task = PlosBioTechCheck::ChangesForAuthorTask.first

    # Author
    login_as(author, scope: :user)
    overlay = Page.view_task_overlay(paper, change_author_task)
    overlay.expect_to_see_change_list
    wait_for_ajax
    overlay.click_changes_have_been_made
    overlay.dismiss

    # Creator cannot access initial tech check task
    visit "/papers/#{paper.id}/tasks/#{task.id}"
    wait_for_ajax
    expect(page).to have_content("You don't have access to that content")
    Warden.test_reset!
  end

  scenario "list the unselected question items in the author changes letter" do
    login_as(editor, scope: :user)
    overlay = Page.view_task_overlay(paper, task)
    overlay.display_letter
    overlay.click_autogenerate_email_button
    textarea = overlay.letter
    expect(textarea.value).to include "In the Ethics statement card, you have selected Yes to one of the questions."
  end

  scenario "selected questions don't show up in the auto-generated author change letter" do
    login_as(editor, scope: :user)
    overlay = Page.view_task_overlay(paper, task)
    overlay.display_letter

    question_elements = all(".question-checkbox")
    first_question = question_elements.first
    first_question.find("input").click
    overlay.click_autogenerate_email_button

    textarea = overlay.letter
    expect(textarea.value).to_not include "In the Ethics statement card, you have selected Yes to one of the questions."
  end

  scenario "unchecking a box with no associated text has no effect" do
    login_as(editor, scope: :user)
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
