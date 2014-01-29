require 'spec_helper'

feature "Paper Submission" do
  include Warden::Test::Helpers
  Warden.test_mode!

  scenario "Author creates a submission" do
    journal = Journal.create! name: 'PLOS One'
    author = User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'

    login_as(author, scope: :user)

    dashboard_page = DashboardPage.visit
    new_submission_page = dashboard_page.new_submission
    edit_submission_page = new_submission_page.create_submission 'This is a short title', journal: 'PLOS One', paper_type: 'Front matter'

    expect(edit_submission_page.journal).to eq('PLOS One')
    dashboard_page = edit_submission_page.visit_dashboard
    expect(dashboard_page.submissions).to include 'This is a short title'
  end
end
