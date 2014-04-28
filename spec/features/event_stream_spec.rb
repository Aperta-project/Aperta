require 'spec_helper'

feature "Event streaming", js: true do
  let!(:author) { FactoryGirl.create :user }
  let!(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "On the dashboard page" do
    expect(page).to have_no_selector(".completed")
    t = author.papers.first.tasks_for_type(UploadManuscriptTask).first
    t.completed = true
    t.save
    expect(page).to have_css(".card-completed", count: 1)
  end

end
