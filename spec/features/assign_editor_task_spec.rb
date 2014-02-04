require 'spec_helper'

feature "Assigns Editor", js: true do

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

  let!(:editor) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      journal_roles: [JournalRole.new(journal: journal, editor: true)]
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email

    Paper.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal,
      user: admin
  end

  scenario "Admin can assign an editor to a paper" do
    dashboard_page = DashboardPage.visit
    paper_page = dashboard_page.view_submitted_paper 'foobar'
    task_manager_page = paper_page.navigate_to_task_manager

    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Editor', :new do |overlay|
      expect(overlay.assignee).to eq 'Please select assignee'
      expect(overlay).to_not be_completed
      overlay.assignee = admin.full_name
      overlay.paper_editor = editor.full_name
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    task_manager_page.reload

    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Editor', :new do |overlay|
      expect(overlay).to be_completed
      expect(overlay.assignee).to eq admin.full_name
      expect(overlay.paper_editor).to eq editor.full_name
    end
  end
end
