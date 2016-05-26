require 'rails_helper'

feature "Inviting a new reviewer", js: true do
  include InvitationFeatureHelpers

  let(:paper) { FactoryGirl.create :paper, :with_integration_journal }
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
    visit_in_email root_path

    dashboard_page = sign_up_as("malz@example.com")
    dashboard_page.accept_invitation_for_paper(paper)

    expect(dashboard_page).to have_submission(paper.title)
  end
end
