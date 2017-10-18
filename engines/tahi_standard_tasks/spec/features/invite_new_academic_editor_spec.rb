require 'rails_helper'

feature "Inviting a new Academic Editor", js: true do
  include InvitationFeatureHelpers

  let(:internal_editor) { create :user, :site_admin }
  let(:paper) do
    FactoryGirl.create(
      :paper, :submitted_lite, :with_integration_journal, creator: internal_editor
    )
  end

  let(:task) { FactoryGirl.create :paper_editor_task, paper: paper }

  before do
    task.add_participant(internal_editor)

    login_as(internal_editor, scope: :user)
    visit "/"
  end

  scenario "Inviting an Academic Editor not currently in the system" do
    invite_new_editor_for_paper "johndoe@example.com", paper
    ensure_email_got_sent_to "johndoe@example.com"
    Page.new.sign_out

    open_email "johndoe@example.com"
    academic_editor = create :user, email: "johndoe@example.com"
    login_as(academic_editor, scope: :user)
    visit_in_email "Accept Invitation"
    expect(page).to have_content(
      "Thank you for agreeing to be an Academic Editor on this #{paper.journal.name} manuscript"
    )
  end

  scenario "Academic Editor can decline without logging in" do
    invite_new_editor_for_paper "johndoe@example.com", paper
    ensure_email_got_sent_to "johndoe@example.com"
    Page.new.sign_out

    open_email "johndoe@example.com"

    visit_in_email "Decline"
    expect(page).to have_content(paper.title)
    page.click_button 'Decline'

    expect(page).to have_content(
      "You’ve successfully declined the invitation to be the Academic Editor for \"#{paper.title}\""
    )
    page.execute_script("tinymce.get('invitation_decline_reason').setContent('No thanks')")
    page.execute_script("tinymce.get('invitation_reviewer_suggestions').setContent('bob@example.com')")
    page.click_button "Send Feedback"
    expect(page).to have_content("Thank You")
    expect(Invitation.last.decline_reason).to eq("<p>No thanks</p>")
    expect(Invitation.last.reviewer_suggestions).to eq("<p>bob@example.com</p>")
  end

  scenario "Academic Editor can see a button to accept after declining in mail" do
    invite_new_editor_for_paper "johndoe@example.com", paper
    ensure_email_got_sent_to "johndoe@example.com"
    Page.new.sign_out

    open_email "johndoe@example.com"
    visit_in_email "Decline"

    expect(page).to have_content("ACCEPT EDITOR INVITATION")
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
    another_editor = create :user, email: 'a-malz-imposter@example.com'
    login_as(another_editor, scope: :user)
    visit_in_email "Accept Invitation"

    expect(page).to have_content("Sorry, we're unable to find the page you requested.")
  end
end
