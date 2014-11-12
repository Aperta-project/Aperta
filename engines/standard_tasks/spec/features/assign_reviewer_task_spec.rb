require 'spec_helper'

feature "Assigns Reviewer", js: true, solr: true do
  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) { FactoryGirl.create(:paper, journal: journal) }
  let(:task) { FactoryGirl.create(:paper_reviewer_task, paper: paper) }

  let(:user) { create :user }
  let!(:albert) { create :user }
  let!(:neil) { create :user }

  before do
    assign_journal_role(journal, user, :editor)
    assign_journal_role(journal, albert, :reviewer)
    assign_journal_role(journal, neil, :reviewer)
    paper.paper_roles.build(user: user, role: PaperRole::COLLABORATOR)
    task.participants << user

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in user
  end

  scenario "Editor can assign a reviewer to a paper" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card task.title do |overlay|
      overlay.paper_reviewers = [albert]
      has_no_css?('#delayedSave', visible: false)
      expect(overlay).to have_no_application_error
      expect(overlay).to have_reviewers(albert)
      # the debounce in the reviewers overlay is causing a race condition between the
      # delayed save and the database truncation during test cleanup.  This will fix it for now.
    end
  end
end
