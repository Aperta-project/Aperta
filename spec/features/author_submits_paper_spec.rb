require 'spec_helper'

feature "Paper Submission" do
  let(:author) { FactoryGirl.create :user }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  scenario "Author creates a submission", js: true do
    journal = create :journal

    dashboard_page = DashboardPage.new
    new_submission_page = dashboard_page.new_submission
    edit_submission_page = new_submission_page.create_submission 'This is a short title', journal: journal.name

    binding.pry
    expect(edit_submission_page.journal).to eq(journal.name)
    dashboard_page = edit_submission_page.visit_dashboard
    expect(dashboard_page.submissions).to include 'This is a short title'
  end
end
