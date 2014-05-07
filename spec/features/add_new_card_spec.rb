require 'spec_helper'

feature 'Add a new card', js: true do
  let(:journal) { create :journal }
  let(:admin) { create :user, admin: true }

  let!(:albert) do
    create :user,
      journal_roles: [JournalRole.new(journal: journal, admin: true)]
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  let(:paper) do
    Paper.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal,
      user: admin
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
