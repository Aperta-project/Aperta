require 'rails_helper'

feature "Paper workflow", js: true, selenium: true do
  let(:admin) { FactoryGirl.create :user }
  let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let!(:paper) { FactoryGirl.create :paper, :submitted, :with_tasks, journal: journal }
  let!(:card) { FactoryGirl.create(:card, :versioned, journal: journal) }


  before do
    assign_journal_role(journal, admin, :admin)
    login_as(admin, scope: :user)
    visit "/papers/#{paper.id}/workflow"
    wait_for_ajax
  end

  describe "navigation" do
    before do
      # ensure that admin is an active participant on the paper
      paper.update(creator: admin)

      visit root_path
    end

    it "navigate from sign in through workflow" do
      click_link paper.title
      click_link "Workflow"

      expect(current_path).to eq "/papers/#{paper.short_doi}/workflow"
    end
  end

  describe "page content" do
    let(:task_manager_page) { TaskManagerPage.new }

    it "display paper name" do
      expect(task_manager_page.paper_title).to have_content(paper.title)
    end
  end

  describe "Adding phases" do
    scenario 'Adding a phase' do
      task_manager_page = TaskManagerPage.new
      phase = task_manager_page.phase 'Submission Data'

      expect { phase.add_phase; expect(page).to have_content "New Phase" }.to change { task_manager_page.phase_count }.by(1)
    end

    scenario 'Preserving order of added phases after reload' do
      task_manager_page = TaskManagerPage.new
      original_phases = task_manager_page.phases
      # put new phases in the second and fourth positions.
      task_manager_page.phase(original_phases[0]).add_phase
      task_manager_page.phase(original_phases[1]).add_phase
      new_phases = TaskManagerPage.new.phases
      expect(new_phases[1]).to eq("New Phase")
      expect(new_phases[3]).to eq("New Phase")
      expect(task_manager_page).to have_no_application_error
      reloaded_phases = TaskManagerPage.new.phases
      expect(reloaded_phases[1]).to eq("New Phase")
      expect(reloaded_phases[3]).to eq("New Phase")
    end
  end

  describe "Removing phases" do
    scenario 'Removing an Empty Phase' do
      task_manager_page = TaskManagerPage.new
      phase = task_manager_page.phase 'Submission Data'
      phase.add_phase
      new_phase = task_manager_page.phase 'New Phase'
      new_phase.remove_phase
      expect(task_manager_page).to have_no_application_error
      expect(task_manager_page).to have_no_content 'New Phase'
    end

    scenario 'Non-empty phase' do
      task_manager_page = TaskManagerPage.new
      phase = task_manager_page.phase 'Submission Data'
      expect(phase).to have_no_remove_icon
    end
  end

  scenario 'Removing a task' do
    task_manager_page = TaskManagerPage.new
    phase = task_manager_page.phase 'Submission Data'
    expect(task_manager_page).to have_no_application_error
    initial_card_count = task_manager_page.card_count

    phase.remove_card('Upload Manuscript')
    within '.overlay' do
      find('.submit-action-buttons button', text: 'Yes, Delete this Card'.upcase).click
    end
    expect(task_manager_page).to_not have_css('.card-title', text: 'Upload Manuscript', visible: false)
    expect(task_manager_page.card_count).to eq(initial_card_count - 1)
  end

  scenario "Adding a new CustomCardTask" do
    task_manager_page = TaskManagerPage.new
    phase = task_manager_page.phase 'Submission Data'
    phase.find('a', text: 'ADD NEW CARD').click

    within '.overlay' do
      find('label', text: card.name).click
      find('button', text: 'ADD').click
    end

    expect(task_manager_page).to have_css('.card-title', text: card.name, visible: false)
  end

  # Preventing a regression
  scenario 'Opening an Invite Reviewers task', flaky: true do
    task_manager_page = TaskManagerPage.new

    within 'body' do
      find('.card-title', text: 'Invite Reviewer').click

      expect(task_manager_page).to have_css('.overlay-body', text: 'Invite Reviewers')
      expect(task_manager_page).to have_css('.overlay-body', text: 'Discussion')
      expect(task_manager_page).to have_no_application_error
    end
  end
end
