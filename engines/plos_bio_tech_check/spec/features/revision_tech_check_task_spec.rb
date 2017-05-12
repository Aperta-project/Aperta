require 'rails_helper'

feature 'Revision Tech Check', js: true do
  let(:journal) { create :journal, :with_roles_and_permissions }
  let(:editor) { create :user }
  let(:author) { create :user }
  let(:paper) { create :paper, :submitted, journal: journal, creator: author }
  let(:task) { create :revision_tech_check_task, :with_loaded_card, paper: paper }
  let(:words) { %w(Data Availability Financial Competing Figure Ethics) }

  before do
    assign_journal_role journal, editor, :editor
  end

  scenario 'Revision Tech Check triggers Changes For Author' do
    # Editor
    login_as(editor, scope: :user)
    overlay = Page.view_task_overlay(paper, task)
    expect(PlosBioTechCheck::ChangesForAuthorTask.count).to eq(0)
    overlay.create_author_changes_card
    overlay.expect_author_changes_saved
    overlay.mark_as_complete
    overlay.dismiss
    logout

    change_author_task = PlosBioTechCheck::ChangesForAuthorTask.first

    # Author
    login_as(author, scope: :user)
    overlay = Page.view_task_overlay(paper, change_author_task)
    overlay.expect_to_see_change_list
    overlay.click_changes_have_been_made
    overlay.dismiss

    # creator cannot access revision tech check task
    Page.view_task task
    expect(page).to have_content("You don't have access to that content")
  end

  scenario "list the unselected question items in the author changes letter" do
    login_as(editor, scope: :user)
    overlay = Page.view_task_overlay(paper, task)
    wait_for_editors
    overlay.display_letter
    overlay.click_autogenerate_email_button
    text = overlay.letter_text
    expect(text).to include(*words)

    question_elements = all(".question-checkbox")
    first_question = question_elements.first
    last_question = question_elements.last
    first_question.find("input").click
    last_question.find("input").click

    text = overlay.letter_text
    expect(text).to_not include first_question.find(".model-question").text
    expect(text).to_not include last_question.find(".model-question").text
  end

  scenario "selected questions don't show up in the auto-generated author change letter" do
    login_as(editor, scope: :user)
    overlay = Page.view_task_overlay(paper, task)
    wait_for_editors
    overlay.display_letter
    overlay.click_autogenerate_email_button
    text = overlay.letter_text
    expect(text).to include(*words)

    question_elements = all(".question-checkbox")
    first_question = question_elements.first
    first_question.find("input").click
    overlay.click_autogenerate_email_button

    text = overlay.letter_text
    expect(text).to_not include('Data, Availability, Financial, Competing, Figure, Ethics')
  end

  scenario "unchecking a box with no associated text has no effect" do
    login_as(editor, scope: :user)
    overlay = Page.view_task_overlay(paper, task)
    wait_for_editors
    overlay.display_letter
    overlay.click_autogenerate_email_button
    text_before = overlay.letter_text

    question_elements = all(".question-checkbox")
    question = question_elements[1]
    question.find("input").click
    overlay.click_autogenerate_email_button

    text_after = overlay.letter_text
    expect(text_before).to eq(text_after)
  end
end
