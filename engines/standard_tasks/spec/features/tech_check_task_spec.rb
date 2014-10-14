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
    task.participants << user

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in user
  end

  scenario "Someone can complete the tech check card from the paper edit page" do
    dashboard_page = DashboardPage.new
    manuscript_page = dashboard_page.view_submitted_paper paper
    manuscript_page.view_card 'Tech Check' do |overlay|
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end
  end
end
