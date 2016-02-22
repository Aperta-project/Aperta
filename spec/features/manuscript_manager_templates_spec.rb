require 'rails_helper'

feature 'Manuscript Manager Templates', js: true, selenium: true do
  let(:admin) { create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:mmt) { journal.manuscript_manager_templates.first }
  let(:mmt_page) { ManuscriptManagerTemplatePage.new }
  let(:task_manager_page) { TaskManagerPage.new }

  before do
    login_as(admin, scope: :user)
    visit "/admin/journals/#{journal.id}/manuscript_manager_templates/#{mmt.id}/edit"
  end

  describe 'Page Content' do
    scenario 'editing a MMT' do
      expect(mmt_page.paper_type).to have_text(mmt.paper_type)
    end
  end

  describe 'Phase Templates' do

    scenario 'Adding a phase' do
      phase = task_manager_page.phase 'Submission Data'
      phase.add_phase
      expect(page).to have_text('New Phase')
    end

    scenario 'Preserving order of added phases after reload' do
      original_phases = task_manager_page.phases
      # put new phases in the second and fourth positions.
      task_manager_page.phase(original_phases[0]).add_phase
      task_manager_page.phase(original_phases[1]).add_phase
      new_phases = TaskManagerPage.new.phases
      expect(new_phases[1]).to eq('New Phase')
      expect(new_phases[3]).to eq('New Phase')
      expect(task_manager_page).to have_no_application_error
      reloaded_phases = TaskManagerPage.new.phases
      expect(reloaded_phases[1]).to eq('New Phase')
      expect(reloaded_phases[3]).to eq('New Phase')
    end

    scenario 'Removing an Empty Phase' do
      phase = task_manager_page.phase 'Submission Data'
      phase.add_phase
      new_phase = task_manager_page.phase 'New Phase'
      new_phase.remove_phase
      expect(task_manager_page).to have_no_application_error
      expect(task_manager_page).to have_no_content 'New Phase'
    end

    scenario 'Removing a Non-empty phase' do
      phase = task_manager_page.phase 'Submission Data'
      expect(phase).to have_no_remove_icon
    end
  end

  describe 'Task Templates' do

    scenario 'Adding a new Task Template'do

      phase = task_manager_page.phase 'Get Reviews'
      phase.find('a', text: 'ADD NEW CARD').click

      expect(task_manager_page).to have_css('.overlay', text: 'Author task cards')
      expect(task_manager_page).to have_css('.overlay', text: 'Staff task cards')
      expect {
        within '.overlay' do
          find('label', text: 'Invite Reviewer').click
          find('button', text: 'ADD').click
        end
      }.to change {
        task_manager_page.card_count
      }.by(1)
    end

    scenario 'Adding multiple Task Templates'do

      phase = task_manager_page.phase 'Get Reviews'
      phase.find('a', text: 'ADD NEW CARD').click

      expect(task_manager_page).to have_css('.overlay', text: 'Author task cards')
      expect(task_manager_page).to have_css('.overlay', text: 'Staff task cards')
      expect {
        within '.overlay' do
          find('label', text: 'Invite Reviewer').click
          find('label', text: 'Register Decision').click
          find('button', text: 'ADD').click
        end
      }.to change {
        task_manager_page.card_count
      }.by(2)
    end

    scenario 'Adding a new Ad-Hoc Task Template'do

      phase = task_manager_page.phase 'Get Reviews'
      phase.find('a', text: 'ADD NEW CARD').click

      within '.overlay' do
        find('label', text: 'Ad-hoc').click
        find('button', text: 'ADD').click
      end

      expect(page).to have_css('.overlay-body h1.inline-edit.editing',
                               text: 'Ad-hoc',
                               visible: false)

      find('.adhoc-content-toolbar .fa-plus').click
      find('.adhoc-content-toolbar .adhoc-toolbar-item--text').click

      # TODO: uncomment when compatible with firefox
      # https://developer.plos.org/jira/browse/APERTA-5480

      # find('.inline-edit-form div[contenteditable]').html("New contenteditable, yahoo!")
      # find('.task-body .inline-edit-body-part .button--green:contains("Save")').click
      # expect(page).to have_css('.inline-edit', text: 'yahoo')
      # find('.inline-edit-body-part .fa-trash').click
      # expect(page).to have_css('.inline-edit-body-part', text: 'Are you sure?')
      # find('.inline-edit-body-part .delete-button').click
      # expect(page).to_not have_css('.inline-edit', text: 'yahoo')
      # find('.overlay-close-button:first').click
    end

    scenario 'Removing a task' do
      phase = task_manager_page.phase 'Submission Data'
      expect {
        phase.remove_card('Upload Manuscript')
        within '.overlay' do
          find('.submit-action-buttons button', text: 'Yes, Delete this Card'.upcase).click
        end
      }.to change {
        task_manager_page.card_count
      }.by(-1)
    end
  end
end
