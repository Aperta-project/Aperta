require 'rails_helper'

feature 'journal admin old_role', js: true do
  let(:user) { create :user }
  let!(:journal) { create :journal }
  let!(:another_journal) { create :journal }

  let(:dashboard) { DashboardPage.new }

  context 'non-admin user with journal admin old_role' do
    before do
      assign_journal_role(journal, user, :admin)
      login_as(user, scope: :user)
      visit '/'
    end

    scenario 'the user can see the admin link on the dashboard' do
      expect(dashboard.admin_link).to be_present
    end

    scenario 'the user can view the admin page for a journal', selenium: true do
      admin_page = dashboard.visit_admin
      expect(admin_page.journal_names).to include(journal.name)
      admin_page.visit_journal(journal)
    end
  end

  context 'non-admin user without journal admin old_role' do
    before do
      login_as(user, scope: :user)
      visit '/'
    end

    scenario 'the user does not see the admin link on the dashboard' do
      expect(dashboard).to have_no_admin_link
    end
  end
end

feature 'author roles', js: true do
  let!(:user) { FactoryGirl.create :user }
  let!(:second_paper) { create :paper, :with_valid_author }
  let!(:reviewer) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create(:journal, :with_doi) }
  let(:dashboard) { DashboardPage.new }

  let!(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      # Add any tasks you want to add to the first phase below
      tasks = [TahiStandardTasks::PaperAdminTask, TahiStandardTasks::DataAvailabilityTask]
      JournalServices::CreateDefaultManuscriptManagerTemplates.make_tasks(phase, journal.journal_task_types, *tasks)
      journal.manuscript_manager_templates = [mmt]
      journal.save!
    end
  end

  context 'Creator Role' do
    before do
      login_as(user, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
    end

    scenario 'creator can see their tasks on a paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'creator cannot see other tasks he/she does not own' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end
  end
end

feature 'editor roles', js: true do
  let!(:author) { FactoryGirl.create :user }
  let!(:second_paper) { create :paper, :with_valid_author }
  let!(:reviewer) { FactoryGirl.create :user }
  let!(:academic_editor) { FactoryGirl.create :user }
  let!(:handling_editor) { FactoryGirl.create :user }
  let!(:internal_editor) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create(:journal, :with_doi) }
  let(:dashboard) { DashboardPage.new }

  let!(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      # Add any tasks you want to add to the first phase below
      tasks = [TahiStandardTasks::PaperAdminTask, TahiStandardTasks::DataAvailabilityTask]
      JournalServices::CreateDefaultManuscriptManagerTemplates.make_tasks(phase, journal.journal_task_types, *tasks)
      journal.manuscript_manager_templates = [mmt]
      journal.save!
    end
  end

  context 'Academic Editor Role' do
    before do
      login_as(author, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
      expect(page).to have_content('Data Availability')

      assign_academic_editor_role(Paper.first, academic_editor)
      logout(:user)
      login_as(academic_editor, scope: :user)
      visit '/'
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'academic editor can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'academic editor cannot see tasks on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end
  end

  context 'Handling Editor Role' do
    before do
      login_as(author, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
      expect(page).to have_content('Data Availability')

      assign_handling_editor_role(Paper.first, handling_editor)
      logout(:user)
      login_as(handling_editor, scope: :user)
      visit '/'
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'handling editor can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'handling editor cannot see tasks on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end
  end

  context 'Internal Editor Role' do
  end
end

feature 'reviewer role', js: true do
  context 'Reviewer Role' do
    before do
      login_as(author, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
      expect(page).to have_content('Data Availability')

      assign_reviewer_role(Paper.first, reviewer)
      logout(:user)
      login_as(reviewer, scope: :user)
      visit '/'
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'reviewer can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'reviewer cannot see tasks on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end
  end
end

feature 'staff roles', js: true do
  context 'Staff Admin Role' do
  end

  context 'Production Staff Role' do
  end

  context 'Publishing Services Role' do
  end
end
