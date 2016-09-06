require 'rails_helper'

feature 'Manuscript Manager Templates', js: true, selenium: true do
  let(:journal_admin) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:mmt) { journal.manuscript_manager_templates.first }
  let(:mmt_page) { ManuscriptManagerTemplatePage.new }
  let(:task_manager_page) { TaskManagerPage.new }

  before do
    assign_journal_role journal, journal_admin, :admin
    login_as(journal_admin, scope: :user)
    visit "/admin/journals/#{journal.id}/manuscript_manager_templates/#{mmt.id}/edit"
  end

  scenario 'Choosing a Reviewer Report Type' do
    check 'Uses research article reviewer report'
    Page.new.reload
    expect(page.has_checked_field?('Uses research article reviewer report')).to be(true)

    uncheck 'Uses research article reviewer report'
    Page.new.reload
    expect(page.has_checked_field?('Uses research article reviewer report')).to be(false)
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
      expect(task_manager_page).to have_css('.card', count: 9)
      within '.overlay' do
        find('label', text: 'Invite Reviewer').click
        find('button', text: 'ADD').click
      end
      expect(task_manager_page).to have_css('.card', count: 10)
    end

    scenario 'Adding multiple Task Templates'do
      phase = task_manager_page.phase 'Get Reviews'
      phase.find('a', text: 'ADD NEW CARD').click

      expect(task_manager_page).to have_css('.overlay', text: 'Author task cards')
      expect(task_manager_page).to have_css('.overlay', text: 'Staff task cards')
      expect(task_manager_page).to have_css('.card', count: 9)
      within '.overlay' do
        find('label', text: 'Invite Reviewer').click
        find('label', text: 'Register Decision').click
        find('button', text: 'ADD').click
      end
      expect(task_manager_page).to have_css('.card', count: 11)
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
    end

    scenario 'Removing a task' do
      expect(task_manager_page).to have_css('.card', count: 9)
      phase = task_manager_page.phase 'Submission Data'
      phase.remove_card('Upload Manuscript')
      within '.overlay' do
        find('.submit-action-buttons button', text: 'Yes, Delete this Card'.upcase).click
      end
      expect(task_manager_page).to have_css('.card', count: 8)
    end
  end
end
