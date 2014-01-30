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
      journal_roles: [JournalRole.new(journal: journal, editor: true)]
  end

  let(:journal) { Journal.create! }

  let!(:albert) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      journal_roles: [JournalRole.new(journal: journal, reviewer: true)]
  end

  let!(:neil) do
    User.create! username: 'neilsbohr',
      first_name: 'Neils',
      last_name: 'Bohr',
      email: 'neil@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'University of Copenhagen',
      journal_roles: [JournalRole.new(journal: journal, reviewer: true)]
  end

  before do
    paper = Paper.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal,
      user: editor

    paper_role = PaperRole.create! paper: paper, user: editor, editor: true

    sign_in_page = SignInPage.visit
    sign_in_page.sign_in editor.email
  end

  scenario "Editor can assign a reviewer to a paper" do
    dashboard_page = DashboardPage.visit
    reviewer_card = dashboard_page.view_card 'Assign Reviewer'
    paper_show_page = reviewer_card.view_paper

    paper_show_page.view_card 'Assign Reviewer' do |overlay|
      overlay.paper_reviewers = [albert.full_name, neil.full_name]
      overlay.mark_as_complete
      expect(overlay).to be_completed
    end

    paper_show_page.reload

    paper_show_page.view_card 'Assign Reviewer' do |overlay|
      expect(overlay).to be_completed
      expect(overlay.paper_reviewers).to include(albert.full_name)
      expect(overlay.paper_reviewers).to include(neil.full_name)
    end
  end
end
