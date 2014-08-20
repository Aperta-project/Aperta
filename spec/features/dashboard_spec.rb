require 'spec_helper'

feature "Dashboard", js: true do
  let!(:user) { FactoryGirl.create :user, admin: true }
  let!(:journal) { FactoryGirl.create :journal }
  let(:paper_count) { 1 }
  let!(:papers) do
    paper_count.times do
      FactoryGirl.create :paper, :with_tasks, journal: journal, submitted: false, user: user
    end
  end
  let(:dashboard) { DashboardPage.new }


  describe "pagination" do
    context "when there are more than 15 papers" do
      let(:paper_count) { 18 }
      scenario "only 15 papers are beamed down but total paper count is present" do
        SignInPage.visit.sign_in user
        expect(dashboard.total_paper_count).to eq paper_count
        expect(dashboard.paper_count).to eq Paper::PAGE_SIZE
        load_more_button = dashboard.load_more_papers_button
        expect(load_more_button).to be_present
        dashboard.load_more_papers
        expect(dashboard).to have_no_css('.load-more-papers')
        expect(dashboard.paper_count).to eq paper_count
      end
    end
  end

  describe "flow manager link" do
    scenario "user is not an admin" do
      user.update(admin: false)
      SignInPage.visit.sign_in user
      expect(dashboard).to_not have_css('.nav-bar-item', text: 'Flow Manager')
    end

    scenario "user is an admin" do
      SignInPage.visit.sign_in user
      expect(dashboard).to have_css('.nav-bar-item', text: 'Flow Manager')
    end
  end

  describe "admin link" do
    scenario "user is not a journal admin" do
      user.update(admin: false)
      SignInPage.visit.sign_in user
      expect(dashboard).to_not have_css('.nav-bar-item', text: 'Admin')
    end
  end
end
