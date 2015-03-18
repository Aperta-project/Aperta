require 'rails_helper'

feature "Manuscript Manager", js: true, selenium: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal }
  let!(:paper) { FactoryGirl.create :paper, :with_tasks, creator: admin, submitted: true, journal: journal }

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
      # put new phases in the second and fourth positions.
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
    task_manager_page = TaskManagerPage.visit paper

    phase = task_manager_page.phase 'Submission Data'
    expect(task_manager_page).to have_no_application_error
    before = task_manager_page.card_count
    expect {
      phase.remove_card('Upload Manuscript')
      within '.overlay' do
        find('.submit-action-buttons button', text: 'Yes, Delete this Card'.upcase).click
      end
    }.to change {
      task_manager_page.card_count
    }.by(-1)

    dashboard_page = task_manager_page.navigate_to_dashboard
    paper_page = dashboard_page.view_submitted_paper paper
    task_manager_page = paper_page.visit_task_manager
    expect(task_manager_page.card_count).to eq(before - 1)
  end

  # Preventing a regression
  scenario 'Opening an Invite Reviewers task' do
    task_manager_page = TaskManagerPage.visit paper

    within 'body' do
      find('.card-content', text: 'Invite Reviewer').click

      expect(task_manager_page).to have_css('.overlay-content', text: 'Invite Reviewers')
      expect(task_manager_page).to have_css('.overlay-content', text: 'Discussion')
      expect(task_manager_page).to have_no_application_error
    end
  end

  scenario "Admin can assign a paper to themselves" do
    task_manager_page = TaskManagerPage.visit paper

    needs_editor_phase = task_manager_page.phase 'Invite Editor'
    needs_editor_phase.view_card 'Assign Admin' do |overlay|
      expect(overlay).to have_no_admin(admin.full_name)
      overlay.admin = admin
      overlay.mark_as_complete
      expect(overlay).to be_completed
      expect(overlay).to have_admin(admin.full_name)
    end

    needs_editor_phase = TaskManagerPage.new.phase 'Invite Editor'
    needs_editor_phase.view_card 'Assign Editor' do |overlay|
      expect(overlay).to_not be_completed
    end
  end
end
