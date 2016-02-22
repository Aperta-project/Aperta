require 'rails_helper'

feature "Invite Admin", js: true do
  let(:site_admin) { FactoryGirl.create(:user, site_admin: true) }
  let(:admin) { FactoryGirl.create(:user) }
  let(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_integration_journal,
      :submitted,
      creator: site_admin
    )
  end
  let!(:task) { FactoryGirl.create(:paper_admin_task, paper: paper, phase: paper.phases.first) }

  before do
    assign_journal_role(paper.journal, admin, :admin)
    login_as(site_admin, scope: :user)
    visit "/"
  end

  scenario "Site Admin can invite a Paper Admin to a Paper", selenium: true do
    dashboard_page = DashboardPage.new
    paper_page = dashboard_page.view_submitted_paper(paper)
    task_manager_page = paper_page.visit_task_manager

    phase = task_manager_page.phase(task.phase.name)
    phase.view_card(task.title) do |overlay|
      expect(overlay).to_not be_completed
      overlay.admin = admin
      overlay.mark_as_complete
      expect(overlay).to be_completed
      expect(overlay).to have_admin admin.email
    end
  end
end
