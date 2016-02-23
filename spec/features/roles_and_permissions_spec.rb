require 'rails_helper'

feature 'author roles', js: true do
  let!(:user) { FactoryGirl.create :user }
  let!(:second_paper) { create :paper, :with_valid_author }
  let!(:reviewer) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:dashboard) { DashboardPage.new }

  let!(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      # Add any tasks you want to add to the first phase below
      tasks = [TahiStandardTasks::PaperAdminTask, TahiStandardTasks::DataAvailabilityTask, PlosBilling::BillingTask]
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

    scenario 'can see their tasks on a paper' do
      expect(page).to have_content('Data Availability')
      expect(page).to have_content('Billing')
    end

    scenario 'cannot see other tasks he/she does not own' do
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
  let!(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:dashboard) { DashboardPage.new }

  let!(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      # Add any tasks you want to add to the first phase below
      tasks = [TahiStandardTasks::PaperAdminTask, TahiStandardTasks::DataAvailabilityTask, PlosBilling::BillingTask]
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

      assign_academic_editor_role(author.papers.first, academic_editor)
      logout(:user)
      login_as(academic_editor, scope: :user)
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'cannot see tasks on other papers' do
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

      assign_handling_editor_role(author.papers.first, handling_editor)
      logout(:user)
      login_as(handling_editor, scope: :user)
      visit '/'
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'cannot see tasks on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end
  end

  context 'Internal Editor Role' do
    before do
      login_as(author, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
      expect(page).to have_content('Data Availability')

      assign_internal_editor_role(author.papers.first, internal_editor)
      logout(:user)
      login_as(internal_editor, scope: :user)
      visit '/'
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'cannot see tasks on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end

    scenario 'cannot see tasks they are not allowed to see' do
      visit "/papers/#{author.papers.first.id}"
      expect(page).not_to have_content('Billing')
    end
  end
end

feature 'reviewer roles', js: true do
  let!(:author) { FactoryGirl.create :user }
  let!(:second_paper) { create :paper, :with_valid_author }
  let!(:reviewer) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:dashboard) { DashboardPage.new }

  let!(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      # Add any tasks you want to add to the first phase below
      tasks = [TahiStandardTasks::PaperAdminTask, TahiStandardTasks::DataAvailabilityTask, PlosBilling::BillingTask]
      JournalServices::CreateDefaultManuscriptManagerTemplates.make_tasks(phase, journal.journal_task_types, *tasks)
      journal.manuscript_manager_templates = [mmt]
      journal.save!
    end
  end

  context 'Reviewer Role' do
    before do
      login_as(author, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
      expect(page).to have_content('Data Availability')

      assign_reviewer_role(author.papers.first, reviewer)
      logout(:user)
      login_as(reviewer, scope: :user)
      visit '/'
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'cannot see billing task on the paper' do
      expect(page).not_to have_content('Billing')
    end

    scenario 'cannot see tasks on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end
  end
end

feature 'staff roles', js: true do
  let!(:author) { FactoryGirl.create :user }
  let!(:second_paper) { create :paper, :with_valid_author }
  let!(:staff_admin) { FactoryGirl.create :user }
  let!(:production_staff) { FactoryGirl.create :user }
  let!(:publishing_services) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let(:dashboard) { DashboardPage.new }

  let!(:mmt) do
    FactoryGirl.create(:manuscript_manager_template, paper_type: "Science!").tap do |mmt|
      phase = mmt.phase_templates.create!(name: "First Phase")
      mmt.phase_templates.create!(name: "Phase With No Tasks")
      # Add any tasks you want to add to the first phase below
      tasks = [TahiStandardTasks::PaperAdminTask, TahiStandardTasks::DataAvailabilityTask, PlosBilling::BillingTask]
      JournalServices::CreateDefaultManuscriptManagerTemplates.make_tasks(phase, journal.journal_task_types, *tasks)
      journal.manuscript_manager_templates = [mmt]
      journal.save!
    end
  end

  context 'Staff Admin Role' do
    before do
      login_as(author, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
      expect(page).to have_content('Data Availability')

      assign_journal_role(journal, staff_admin, :admin)
      logout(:user)
      login_as(staff_admin, scope: :user)
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'can see tasks even on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end

    # This should be re-enabled when those with billing task permissions
    # are able to see the billing task
    xscenario 'can see the billing task on the paper' do
      expect(page).to have_content('Billing')
    end
  end

  context 'Production Staff Role' do
    before do
      login_as(author, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
      expect(page).to have_content('Data Availability')

      assign_production_staff_role(journal, production_staff)
      logout(:user)
      login_as(production_staff, scope: :user)
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'can see tasks even on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end

    # This should be re-enabled when those with billing task permissions
    # are able to see the billing task
    xscenario 'can see the billing task on the paper' do
      expect(page).to have_content('Billing')
    end
  end

  context 'Publishing Services Role' do
    before do
      login_as(author, scope: :user)
      visit '/'
      find('.button-primary', text: 'CREATE NEW SUBMISSION').click
      dashboard.fill_in_new_manuscript_fields('A Great Paper Title', journal.name, journal.paper_types[0])
      attach_file 'upload-files', Rails.root.join('spec', 'fixtures', 'about_turtles.docx'), visible: false
      expect(page).to have_content('Data Availability')

      assign_publishing_services_role(journal, publishing_services)
      logout(:user)
      login_as(publishing_services, scope: :user)
      visit "/papers/#{author.papers.first.id}"
    end

    scenario 'can see tasks on the paper' do
      expect(page).to have_content('Data Availability')
    end

    scenario 'can see tasks even on other papers' do
      visit "/papers/#{second_paper.id}"
      expect(page).not_to have_content('Data Availability')
    end

    # This should be re-enabled when those with billing task permissions
    # are able to see the billing task
    xscenario 'can see the billing task on the paper' do
      expect(page).to have_content('Billing')
    end
  end
end
