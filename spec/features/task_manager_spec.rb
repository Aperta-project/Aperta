require 'spec_helper'

feature "Task Manager", js: true do
  include ActionView::Helpers::JavaScriptHelper

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

  let(:author) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      admin: true
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  scenario "Admin can assign a paper to themselves" do
    paper = author.papers.create! short_title: 'foobar', title: 'Foo bar', submitted: true, journal: Journal.create!
    dashboard_page = DashboardPage.visit
    paper_page = dashboard_page.view_submitted_paper 'foobar'
    task_manager_page = paper_page.navigate_to_task_manager

    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Admin' do |overlay|
      expect(overlay.assignee).not_to eq 'Zoey Bob'
      overlay.assignee = 'Zoey Bob'
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    task_manager_page.reload
    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Admin' do |overlay|
      expect(overlay).to be_completed
      expect(overlay.assignee).to eq 'Zoey Bob'
    end

    needs_editor_phase = TaskManagerPage.new.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Editor' do |overlay|
      expect(overlay).to_not be_completed
      expect(overlay.assignee).to eq 'Zoey Bob'
    end
  end
end
