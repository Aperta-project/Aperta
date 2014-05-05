require 'spec_helper'

feature "Tech Check", js: true do
  let(:user) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal }

  before do
    paper = Paper.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal,
      user: user

    make_user_journal_admin(user, paper)

    phase = paper.task_manager.phases.where(name: 'Assign Editor').first
    task = phase.tasks.where(title: 'Tech Check').first
    task.update! assignee: user

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in user.email
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

    paper_show_page.reload

    paper_show_page.view_card 'Tech Check' do |overlay|
      expect(overlay).to be_completed
    end
  end
end
