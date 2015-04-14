require 'rails_helper'

feature "Invite Reviewer", js: true do
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }
  let!(:reviewer1) { create :user }
  let!(:reviewer2) { create :user }

  before do
    assign_journal_role journal, editor, :editor
    assign_journal_role journal, reviewer1, :reviewer
    assign_journal_role journal, reviewer2, :reviewer
    paper.paper_roles.create user: editor, role: PaperRole::COLLABORATOR
    task.participants << editor

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in editor
  end

  scenario "Editor can invite a reviewer to a paper" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer1]
      has_no_css? '#delayedSave', visible: false
      expect(overlay).to have_no_application_error
      expect(overlay).to have_reviewers reviewer1
      # the debounce in the reviewers overlay is causing a race condition between the
      # delayed save and the database truncation during test cleanup.  This will fix it for now.
    end
  end

  scenario "displays invitations from the latest round of revisions" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer2, reviewer1]
      expect(overlay.active_invitations.count).to eq 2
    end

    paper.create_decision!

    manuscript_page.reload
    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer2, reviewer1]
      expect(overlay.active_invitations.count).to eq 2
      expect(overlay.expired_invitations.count).to eq 2
      expect(overlay.total_invitations.count).to eq 4
    end

  end
end
