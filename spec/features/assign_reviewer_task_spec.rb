require 'spec_helper'

feature "Assigns Reviewer", js: true do

  let(:editor) do
    User.create! username: 'zoey',
      first_name: 'Zoey',
      last_name: 'Bob',
      email: 'hi@example.com',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'PLOS',
      admin: true,
      journal_roles: [JournalRole.new(journal: journal, editor: true)]
  end

  let(:journal) { Journal.create! }

  let!(:reviewer) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      journal_roles: [JournalRole.new(journal: journal, reviewer: true)]
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in editor.email

    paper = Paper.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal
  end

  scenario "Editor can assign a reviewer to a paper" do
    dashboard_page = DashboardPage.visit
    editor_card = dashboard_page.view_card 'Assign Reviewers'
    paper_show_page = editor_card.view_paper
    paper_show_page.view_card 'Assign Reviewers' do |overlay|
      overlay.paper_reviewer = reviewer.full_name
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    paper_show_page.reload

    paper_show_page.view_card 'Assign Reviewers' do |overlay|
      expect(overlay).to be_completed
      expect(overlay.paper_reviewer).to eq(reviewer.full_name)
    end
  end
end
