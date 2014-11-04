require 'spec_helper'

feature "Manuscript Manager", js: true, selenium: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal }
  let!(:paper) { FactoryGirl.create :paper, :with_tasks, user: admin, submitted: true, journal: journal }

  before do
    assign_journal_role(journal, admin, :admin)

    page.driver.browser.manage.window.maximize

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  describe "Adding phases" do
    scenario 'Adding a phase' do
      task_manager_page = TaskManagerPage.visit paper
      phase = task_manager_page.phase 'Submission Data'

      expect { phase.add_phase; expect(page).to have_content "New Phase" }.to change { task_manager_page.phase_count }.by(1)
    end

    scenario 'Preserving order of added phases after reload' do
      task_manager_page = TaskManagerPage.visit paper
      original_phases = task_manager_page.phases
      # put new phases in the second and forth positions.
      task_manager_page.phase(original_phases[0]).add_phase
      task_manager_page.phase(original_phases[1]).add_phase
      new_phases = TaskManagerPage.new.phases
      expect(new_phases[1]).to eq("New Phase")
      expect(new_phases[3]).to eq("New Phase")
      expect(task_manager_page).to have_no_application_error
      task_manager_page.reload
      reloaded_phases = TaskManagerPage.new.phases
      expect(reloaded_phases[1]).to eq("New Phase")
      expect(reloaded_phases[3]).to eq("New Phase")

    end
  end

  describe "Removing phases" do
    scenario 'Removing an Empty Phase' do
      task_manager_page = TaskManagerPage.visit paper
      phase = task_manager_page.phase 'Submission Data'
      phase.add_phase
      new_phase = task_manager_page.phase 'New Phase'
      new_phase.remove_phase
      expect(task_manager_page).to have_no_application_error
      expect(task_manager_page).to have_no_content 'New Phase'
    end

    scenario 'Non-empty phase' do
      task_manager_page = TaskManagerPage.visit paper
      phase = task_manager_page.phase 'Submission Data'
      expect(phase).to have_no_remove_icon
    end
  end

  scenario 'Removing a task' do
    dashboard_page = DashboardPage.new
    paper_page = dashboard_page.view_submitted_paper paper
    task_manager_page = paper_page.visit_task_manager

    phase = task_manager_page.phase 'Submission Data'
    expect(task_manager_page).to have_no_application_error
    expect {
      phase.remove_card('Upload Manuscript')
    }.to change { phase.card_count }.by(-1)
  end

  scenario "Admin can assign a paper to themselves" do
    dashboard_page = DashboardPage.new
    paper_page = dashboard_page.view_submitted_paper paper
    task_manager_page = paper_page.visit_task_manager

    expect(task_manager_page).to have_content 'Assign Editor'
    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Admin' do |overlay|
      expect(overlay).to have_no_admin(admin.full_name)
      overlay.admin = admin.full_name
      overlay.mark_as_complete
      expect(overlay).to be_completed
      expect(overlay).to have_admin(admin.full_name)
    end

    expect(task_manager_page).to have_no_application_error

    needs_editor_phase = TaskManagerPage.new.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Editor' do |overlay|
      expect(overlay).to_not be_completed
    end
  end
end
