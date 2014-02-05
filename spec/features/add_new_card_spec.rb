require 'spec_helper'

feature 'Add a new card', js: true do
  let(:admin) do
    User.create! username: 'zoey',
      first_name: 'Zoey',
      last_name: 'Bob',
      email: 'hi@example.com',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'PLOS',
      admin: true
  end

  let!(:albert) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      admin: true,
      journal_roles: [JournalRole.new(journal: journal, editor: true)]
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  let(:journal) { Journal.create! }

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
    needs_editor_phase.new_card title: 'Verify Author Signatures',
      body: 'Please remember to verify signatures of every paper author.',
      assignee: albert

    # needs_editor_phase.view_card 'Verify Author Signatures' do |overlay|
    #   expect(overlay.assignee).to eq 'Albert Einstein'
    #   expect(overlay.title).to eq 'Verify Author Signatures'
    #   expect(overlay.body).to eq 'Please remember to verify signatures of every paper author.'
    # end

    task_manager_page.reload

    needs_editor_phase = task_manager_page.phase 'Assign Editor'
    needs_editor_phase.view_card 'Verify Author Signatures', :new do |overlay|
      expect(overlay.assignee).to eq 'Albert Einstein'
      expect(overlay.title).to eq 'Verify Author Signatures'
      expect(overlay.body).to eq 'Please remember to verify signatures of every paper author.'
    end
  end
end
