require 'spec_helper'

feature "Tech Check", js: true do
  let(:admin) do
    User.create! username: 'zoey',
      first_name: 'Zoey',
      last_name: 'Bob',
      email: 'hi@example.com',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'PLOS',
      admin: true
  end

  let(:journal) { Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email

    paper = Paper.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal,
      user: admin

    phase = paper.task_manager.phases.where(name: 'Assign Editor').first
    task = phase.tasks.where(title: 'Tech Check').first
    task.update! assignee: admin
  end

  scenario "Admin can complete the tech check card" do
    dashboard_page = DashboardPage.visit
    tech_check_card = dashboard_page.view_card 'Tech Check'
    paper_show_page = tech_check_card.view_paper

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
