require 'rails_helper'

feature "Inviting a new reviewer", js: true do
  include InvitationFeatureHelpers

  let(:paper) do
    FactoryGirl.create(
      :paper, :submitted_lite, :with_integration_journal)
  end
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
    reviewer = create :user, email: 'malz@example.com'
    login_as(reviewer, scope: :user)
    visit_in_email root_path
    dashboard_page = DashboardPage.new
    expect(page).to have_content("You have 1 invitation")
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
      "You've successfully declined the invitation to review"
    )
    page.fill_in "invitation_decline_reason", with: "I don't want to"
    page.fill_in "invitation_reviewer_suggestions", with: "bob@example.com"
    page.click_button "Send Feedback"
    expect(page).to have_content("Thank You")
    expect(Invitation.last.decline_reason).to eq("I don't want to")
    expect(Invitation.last.reviewer_suggestions).to eq("bob@example.com")
  end

  scenario "Invitation token cannot be re-used" do
    invite_new_reviewer_for_paper "malz@example.com", paper
    ensure_email_got_sent_to "malz@example.com"
    Page.new.sign_out

    open_email "malz@example.com"
    invitation_link = root_path
    visit_in_email invitation_link

    dashboard_page = sign_up_as("malz@example.com")
    dashboard_page.accept_invitation_for_paper(paper)
    expect(dashboard_page).to have_submission(paper.title)
    dashboard_page.sign_out

    visit invitation_link
    expect(page).to have_content(
      "Welcome to Aperta Submit & manage manuscripts."
    )

    dashboard_page = sign_up_as("a-malz-imposter@example.com")
    expect(dashboard_page).to have_no_content('View invitations')
    expect(dashboard_page).to have_no_submission(paper.title)
  end
end
