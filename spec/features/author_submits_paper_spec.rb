require 'spec_helper'

feature "Paper Submission" do
  include Warden::Test::Helpers
  Warden.test_mode!

  scenario "Author creates a submission", js: true do
    journal = create :journal
    author = create :user

    login_as(author, scope: :user)

    dashboard_page = DashboardPage.visit
    new_submission_page = dashboard_page.new_submission
    edit_submission_page = new_submission_page.create_submission 'This is a short title', journal: journal.name

    expect(edit_submission_page.journal).to eq journal.name
    dashboard_page = edit_submission_page.visit_dashboard
    expect(dashboard_page.submissions).to include 'This is a short title'
  end
end
