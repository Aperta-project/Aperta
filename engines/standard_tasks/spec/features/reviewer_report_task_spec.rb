require 'spec_helper'

feature "Reviewer Report", js: true do
  let(:journal) { FactoryGirl.create :journal }
  let!(:reviewer) { FactoryGirl.create :user }
  let(:paper) { FactoryGirl.create(:paper) }
  let(:task) { FactoryGirl.create(:reviewer_report_task, paper: paper) }

  before do
    paper.paper_roles.create!(user: reviewer, role: PaperRole::COLLABORATOR)
    task.participants << reviewer
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in reviewer
  end

  scenario "Reviewer can write a reviewer report" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper(paper)
    manuscript_page.view_card(task.title) do |overlay|
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end
  end
end
