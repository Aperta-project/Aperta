require 'spec_helper'

feature 'Add a new card', js: true do
  let(:admin) { create :user, admin: true }

  let(:journal) { FactoryGirl.create :journal, :with_default_template }
  let(:paper) do
    FactoryGirl.create :paper, :with_tasks, user: admin, submitted: true, journal: journal
  end

  let!(:albert) { create :user }

  before do
    assign_journal_role(journal, albert, :admin)
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  scenario "Admin can add a new card" do
    task_manager_page = TaskManagerPage.visit paper

    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.new_card overlay: NewAdhocCardOverlay,
      title: 'Verify Author Signatures',
      body: 'Please remember to verify signatures of every paper author.',
      assignee: albert

    expect(task_manager_page).to have_content('Verify Author Signatures')
    needs_editor_phase.view_card 'Verify Author Signatures' do |overlay|
      expect(overlay.assignee).to eq albert.full_name.upcase
      expect(overlay.title).to eq 'Verify Author Signatures'
      expect(overlay.body).to eq 'Please remember to verify signatures of every paper author.'
    end
  end
end
