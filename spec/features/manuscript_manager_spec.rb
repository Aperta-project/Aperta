require 'spec_helper'

feature "Manuscript Manager", js: true do
  let(:admin) { create :user, admin: true }
  let!(:journal) { FactoryGirl.create :journal, :with_default_template }
  let!(:paper) { FactoryGirl.create :paper, :with_tasks, user: admin, submitted: true, journal: journal }

  before do
    JournalRole.create! admin: true, journal: journal, user: admin

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
      new_phases = task_manager_page.phases
      expect(new_phases[1]).to eq("New Phase")
      expect(new_phases[3]).to eq("New Phase")
      task_manager_page.reload
      reloaded_phases = task_manager_page.phases
      expect(reloaded_phases[1]).to eq("New Phase")
      expect(reloaded_phases[3]).to eq("New Phase")

    end
  end

  describe "Removing phases" do
    scenario 'Removing an Empty Phase' do
      task_manager_page = TaskManagerPage.visit paper
      phase = task_manager_page.phase 'Submission Data'
      phase.add_phase
      task_manager_page.reload
      new_phase = task_manager_page.phase 'New Phase'
      expect { new_phase.remove_phase; sleep 0.4 }.to change { task_manager_page.phase_count }.by(-1)
    end

    scenario 'Non-empty phase' do
      task_manager_page = TaskManagerPage.visit paper
      phase = task_manager_page.phase 'Submission Data'
      expect(phase.all('.remove-icon')).to be_empty
    end
  end

  scenario 'Removing a task' do
    dashboard_page = DashboardPage.visit
    paper_page = dashboard_page.view_submitted_paper paper.short_title
    task_manager_page = paper_page.visit_task_manager

    phase = task_manager_page.phase 'Submission Data'
    expect { phase.remove_card('Upload Manuscript') }.to change { phase.card_count }.by(-1)
  end

  scenario "Admin can assign a paper to themselves" do
    dashboard_page = DashboardPage.visit
    paper_page = dashboard_page.view_submitted_paper paper.short_title
    task_manager_page = paper_page.visit_task_manager

    sleep 0.4
    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Admin' do |overlay|
      expect(overlay.assignee).not_to eq admin.full_name
      overlay.assignee = admin.full_name
      overlay.mark_as_complete
      expect(overlay).to be_completed
      expect(overlay.assignee).to eq admin.full_name
    end

    task_manager_page.reload
    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Admin' do |overlay|
      expect(overlay).to be_completed
      expect(overlay.assignee).to eq admin.full_name
    end

    needs_editor_phase = TaskManagerPage.new.phase 'Assign Editor'
    needs_editor_phase.view_card 'Assign Editor' do |overlay|
      expect(overlay).to_not be_completed
      expect(overlay.assignee).to eq admin.full_name.upcase
    end
  end

  scenario 'Renaming a phase' do
    # TODO: Make this work
    # dashboard_page = DashboardPage.visit
    # paper_page = dashboard_page.view_submitted_paper paper.short_title
    # task_manager_page = paper_page.visit_task_manager

    # sleep 0.4
    # phase = task_manager_page.phase 'Assign Editor'
    # execute_script("return $('.column h2')[0].classList.add('changedColumn')")
    # title = phase.all('.column h2').first
    # title.set "Some Other Title"
    # binding.pry
    # execute_script("return $('.changedColumn').blur()")
    # page.reload
  end
end
