require 'rails_helper'
require 'support/invitation_feature_helpers'
require 'support/rich_text_editor_helpers'

feature "Inviting a new reviewer", js: true do
  include InvitationFeatureHelpers
  include RichTextEditorHelpers

  let(:paper) do
    FactoryGirl.create(
      :paper, :submitted_lite, :with_integration_journal)
  end
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }

  before do
    FactoryGirl.create :feature_flag, name: "PREPRINT"

    assign_journal_role paper.journal, editor, :editor
    assign_handling_editor_role paper, editor
    task.add_participant(editor)

    login_as(editor, scope: :user)
  end

  scenario "Inviting a reviewer not currently in the system" do
    invite_new_reviewer_for_paper "malz@example.com", paper
    ensure_email_got_sent_to "malz@example.com"
    Page.new.sign_out

    open_email "malz@example.com"
    reviewer = create :user, email: 'malz@example.com'
    login_as(reviewer, scope: :user)
    visit_in_email root_path
    expect(page).to have_content("Thank you for agreeing to review for #{paper.journal.name}.")
  end

  scenario "Reviewer can decline without logging in" do
    invite_new_reviewer_for_paper "malz@example.com", paper
    ensure_email_got_sent_to "malz@example.com"
    Page.new.sign_out

    open_email "malz@example.com"

    visit_in_email "Decline"
    expect(page).to have_content(
      "ACCEPT REVIEWER INVITATION"
    )
    expect(page).to have_content(paper.title)
    page.click_button 'Decline'
    expect(page).to have_content(
      "You've successfully declined the invitation to be the Reviewer for \"#{paper.title}\""
    )
    wait_for_editors
    set_rich_text(editor: 'declineReason', text: 'No thanks')
    set_rich_text(editor: 'reviewerSuggestions', text: 'bob@example.com')
    page.click_button "Send Feedback"
    wait_for_ajax
    expect(page).to have_content("Thank You")
    expect(Invitation.last.decline_reason).to eq("<p>No thanks</p>")
    expect(Invitation.last.reviewer_suggestions).to eq("<p>bob@example.com</p>")
  end

  scenario "Invitation token cannot be re-used" do
    invite_new_reviewer_for_paper "malz@example.com", paper
    ensure_email_got_sent_to "malz@example.com"
    Page.new.sign_out

    visit '/'

    dashboard_page = sign_up_as("malz@example.com")
    dashboard_page.accept_invitation_for_paper(paper)
    dashboard_page.sign_out

    open_email "malz@example.com"
    reviewer = create :user, email: 'a-malz-imposter@example.com'
    login_as(reviewer, scope: :user)
    visit_in_email root_path

    expect(page).to have_content("Sorry, we're unable to find the page you requested.")
  end
end
