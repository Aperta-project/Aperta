require 'spec_helper'

feature "Event streaming", js: true do
  let!(:author) { FactoryGirl.create :user }
  let!(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }
  let(:upload_task) { author.papers.first.tasks_for_type(UploadManuscriptTask).first }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "On the dashboard page" do
    # Weird race condition if this test doesn't run first.
    sleep 0.3
    expect(page).to have_no_selector(".completed")
    upload_task.completed = true
    upload_task.save
    expect(page).to have_css(".card-completed", count: 1)
  end

  scenario "On the edit paper page" do
    EditPaperPage.visit paper
    expect(page).to have_no_selector(".completed")
    upload_task.completed = true
    upload_task.save
    expect(page).to have_css(".card-completed", count: 1)
  end

end
