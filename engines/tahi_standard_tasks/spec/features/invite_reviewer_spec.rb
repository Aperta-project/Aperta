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
    paper.paper_roles.create user: editor, role: PaperRole::COLLABORATOR
    task.participants << editor

    login_as editor
    visit "/"
  end

  scenario "Editor can invite any user as a reviewer to a paper" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer1]
      expect(overlay).to have_reviewers reviewer1.full_name
    end
  end

  scenario "displays invitations from the latest round of revisions" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper

    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer1]
      expect(overlay.active_invitations_count(1)).to be true
    end

    paper.decisions.create!

    manuscript_page.reload
    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [reviewer3, reviewer2]
      expect(overlay.expired_invitations_count(1)).to be true
      expect(overlay.active_invitations_count(2)).to be true
      expect(overlay.total_invitations_count(3)).to be true
    end
  end
end
