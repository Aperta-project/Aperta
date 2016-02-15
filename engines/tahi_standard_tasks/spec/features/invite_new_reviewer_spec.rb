require 'rails_helper'

feature "Inviting a new reviewer", js: true do
  include InvitationFeatureHelpers

  let(:paper) { FactoryGirl.create :paper }
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }

  before do
    assign_journal_role paper.journal, editor, :editor
    assign_handling_editor_role paper, editor
    task.add_participant(editor)

    login_as(editor, scope: :user)
    visit "/"
  end

  scenario "Inviting a reviewer not currently in the system" do
    invite_new_reviewer_for_paper "malz@example.com", paper
    ensure_email_got_sent_to "malz@example.com"
    Page.new.sign_out

    open_email "malz@example.com"
    visit_in_email root_path(invitation_code: Invitation.last.code)
    expect(page).to have_content("To accept or decline your invitation, please sign in or create an account.")

    dashboard_page = sign_up_as("malz@example.com")
    dashboard_page.accept_invitation_for_paper(paper)

    skip
    # # this next line is flaky
    # expect(dashboard_page).to have_submission(paper.title)
  end

  scenario "Invitation code cannot be re-used" do
    invite_new_reviewer_for_paper "malz@example.com", paper
    ensure_email_got_sent_to "malz@example.com"
    Page.new.sign_out

    open_email "malz@example.com"
    invitation_link = root_path(invitation_code: Invitation.last.code)
    visit_in_email invitation_link

    dashboard_page = sign_up_as("malz@example.com")
    dashboard_page.accept_invitation_for_paper(paper)
    expect(dashboard_page).to have_submission(paper.title)
    dashboard_page.sign_out

    visit invitation_link
    expect(page).to have_content("We're sorry, the invitation is no longer active.")

    dashboard_page = sign_up_as("a-malz-imposter@example.com")
    expect(dashboard_page).to_not have_content('View invitations')
    expect(dashboard_page).to_not have_submission(paper.title)
  end
end
