require 'spec_helper'

feature "Paper Submission" do
  let(:author) { FactoryGirl.create :user }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author creates a submission", js: true, selenium: true do
    journal = create :journal

    dashboard_page = DashboardPage.new
    new_submission_page = dashboard_page.new_submission
    edit_submission_page = new_submission_page.create_submission 'This is a short title', journal: journal.name

    expect(edit_submission_page).to have_journal(journal.name)
    dashboard_page = edit_submission_page.visit_dashboard
    expect(dashboard_page).to have_submission 'This is a short title'
  end
end
