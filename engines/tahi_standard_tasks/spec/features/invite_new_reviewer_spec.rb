require 'rails_helper'

feature "Inviting a new reviewer", js: true do
  include SidekiqHelperMethods

  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }

  before do
    assign_journal_role journal, editor, :editor
    paper.paper_roles.create user: editor, role: PaperRole::COLLABORATOR
    task.participants << editor

    login_as editor
    visit "/"
  end

  scenario "Inviting a reviewer not currently in the system" do
    #
    # First step: invite the user and sign out.
    #
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card task.title do |overlay|
      overlay.invite_new_reviewer "malz@example.com"
      expect(overlay).to have_reviewers "malz@example.com"
    end
    dashboard_page.sign_out

    #
    # Second step: make sure that invitation email gets sent out
    #
    expect {
      process_sidekiq_jobs
    }.to change(ActionMailer::Base.deliveries, :count)
    expect(find_email("malz@example.com")).to_not be_nil


    #
    # Third step: make sure the user can open the email and click on a link
    # that brings them to the site to sign up.
    #
    open_email "malz@example.com"
    visit_in_email root_path(invitation_code: Invitation.last.code)


    #
    # Fourth step: Go through the sign up process and verify that we have
    # been invited to the paper.
    #
    click_on "Sign up"
    dashboard_page = SignUpPage.new.sign_up_as(
      username: "malz",
      first_name: "Malz",
      last_name: "Smith",
      email: "malz@example.com",
      password: "password123"
    )
    dashboard_page.view_invitations do |invitations|
      expect(invitations.count).to eq 1
      invitation = invitations.first
      expect(invitation.text).to match(paper.title)
      invitation.accept
    end
    process_sidekiq_jobs

    expect(dashboard_page).to have_submission(paper.title)
  end
end
