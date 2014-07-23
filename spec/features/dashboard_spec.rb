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

  before { SignInPage.visit.sign_in user }

  describe "pagination" do
    context "when there are more than 15 papers" do
      let(:paper_count) { 18 }
      scenario "only 15 papers are beamed down but total paper count is present" do
        expect(dashboard.total_paper_count).to eq paper_count
        expect(dashboard.paper_count).to eq Paper::PAGE_SIZE
        load_more_button = dashboard.load_more_papers_button
        expect(load_more_button).to be_present
        dashboard.load_more_papers
        expect(dashboard.paper_count).to eq paper_count
        expect do
          dashboard.load_more_papers_button
        end.to raise_error Capybara::ElementNotFound
      end
    end
  end
end
