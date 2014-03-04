require 'spec_helper'

feature "Manuscript Manager", js: true do
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

  let(:paper) { author.papers.create! short_title: 'foobar', title: 'Foo bar', submitted: true, journal: Journal.create! }

  before do
    JournalRole.create! admin: true, journal: paper.journal, user: admin

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  scenario 'Adding new phases' do
    dashboard_page = DashboardPage.visit
    paper_page = dashboard_page.view_submitted_paper 'foobar'
    task_manager_page = paper_page.navigate_to_task_manager

    sleep 0.4
    add_columns = all('.add-column')
    add_columns = page.execute_script('return document.querySelectorAll(".add-column")')
    original_count = add_columns.count
    add_columns.first.click
    sleep 0.4
    expect(
      page.execute_script('return document.querySelectorAll(".add-column")').length
    ).to eq(original_count + 1)
  end

  scenario 'Removing a task' do
    dashboard_page = DashboardPage.visit
    paper_page = dashboard_page.view_submitted_paper 'foobar'
    task_manager_page = paper_page.navigate_to_task_manager

    phase = task_manager_page.phase 'Submission Data'
    remove_card_buttons = phase.all('.remove-card', visible: false)
    original_count = remove_card_buttons.count
    phase.all('.card').first.hover
    remove_card_buttons.first.click
    expect(phase.all('.remove-card', visible: false).count).to be(original_count - 1)
  end

  scenario "Admin can assign a paper to themselves" do
    dashboard_page = DashboardPage.visit
    paper_page = dashboard_page.view_submitted_paper 'foobar'
    task_manager_page = paper_page.navigate_to_task_manager

    sleep 0.4
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
