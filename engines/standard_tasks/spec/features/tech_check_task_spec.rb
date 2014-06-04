require 'spec_helper'

feature "Tech Check", js: true do
  let(:user) { create :user }
  let(:journal) { create :journal }

  let(:journal) { FactoryGirl.create(:journal) }
  let(:paper) do
    FactoryGirl.create(:paper, :with_tasks, journal: journal, user: user, submitted: true)
  end

  before do
    assign_journal_role(paper.journal, user, :admin)

    phase = paper.phases.where(name: 'Assign Editor').first
    task = phase.tasks.where(title: 'Tech Check').first
    task.update! assignee: user

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in user
  end

  scenario "Journal Admin can complete the tech check card" do
    dashboard_page = DashboardPage.visit
    tech_check_card = dashboard_page.view_card 'Tech Check'
    paper_show_page = tech_check_card.view_paper

    visit current_path

    paper_show_page.view_card 'Tech Check' do |overlay|
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

  end
end
