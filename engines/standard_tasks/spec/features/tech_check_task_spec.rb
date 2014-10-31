require 'spec_helper'

feature "Tech Check", js: true do
  let(:user) { create :user }
  let(:paper) { FactoryGirl.create(:paper, user: user, submitted: true) }
  let!(:task) { FactoryGirl.create(:tech_check_task, paper: paper) }

  before do
    assign_journal_role(paper.journal, user, :admin)
    task.participants << user

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in user
  end

  scenario "Someone can complete the tech check card from the paper edit page" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card(task.title) do |overlay|
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end
  end
end
