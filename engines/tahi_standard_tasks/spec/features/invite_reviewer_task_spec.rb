require 'rails_helper'

feature "Invite Reviewer", js: true do
  let(:journal) { FactoryGirl.create :journal }
  let(:paper) { FactoryGirl.create :paper, journal: journal }
  let(:task) { FactoryGirl.create :paper_reviewer_task, paper: paper }

  let(:editor) { create :user }
  let!(:reviewer1) { create :user }
  let!(:reviewer2) { create :user }
  let!(:reviewer3) { create :user }

  before do
    assign_journal_role journal, editor, :editor
    assign_journal_role journal, reviewer1, :reviewer
    assign_journal_role journal, reviewer2, :reviewer
    assign_journal_role journal, reviewer3, :reviewer
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
      expect(overlay).to have_reviewers reviewer1
    end
  end

  scenario "displays invitations from the latest round of revisions" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper

    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer1]
      expect(overlay.active_invitations.count).to eq 1
    end

    paper.decisions.create!

    manuscript_page.reload
    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer3, reviewer2]
      expect(overlay.expired_invitations.count).to eq 1
      expect(overlay.active_invitations.count).to eq 2
      expect(overlay.total_invitations.count).to eq 3
    end

  end
end
