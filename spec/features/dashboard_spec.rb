require 'rails_helper'

feature "Dashboard", js: true do
  let!(:user) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal }
  let(:paper_count) { 1 }
  let!(:papers) do
    paper_count.times.map do
      FactoryGirl.create :paper, :with_tasks, journal: journal, creator: user
    end
  end
  let(:dashboard) { DashboardPage.new }

  feature "pagination" do
    context "when there are more than 15 papers" do
      let(:paper_count) { 18 }
      scenario "only 15 papers are beamed down but total paper count is present" do
        login_as user
        visit "/"
        expect(dashboard.total_paper_count).to eq paper_count
        expect(dashboard.paper_count).to eq Paper.default_per_page
        load_more_button = dashboard.load_more_papers_button
        expect(load_more_button).to be_present
        dashboard.load_more_papers
        expect(dashboard).to have_no_css('.load-more-papers')
        expect(dashboard.paper_count).to eq paper_count
      end
    end
  end

  feature "displaying invitations" do
    let(:paper) { papers.first }
    let!(:phase) { FactoryGirl.create :phase, paper: paper }
    let!(:task) { FactoryGirl.create :invitable_task, phase: phase }
    let(:paper_count) { 3 }

    before do
      decision = paper.decisions.create!
      (FactoryGirl.create :invitation, task: task, invitee: user, decision: decision).invite!
      (FactoryGirl.create :invitation, task: task, invitee: user, decision: decision).invite!
    end

    scenario "only displays invitations from latest revision cycle" do
      login_as user
      visit "/"

      dashboard.expect_active_invitations_count(2)
      decision = paper.decisions.create!
      dashboard.reload

      dashboard.expect_active_invitations_count(0)
      (FactoryGirl.create :invitation, task: task, invitee: user, decision: decision).invite!
      dashboard.reload

      dashboard.expect_active_invitations_count(1)
      dashboard.view_invitations do |invitations|
        expect(invitations.count).to eq 1
        invitations.first.reject
        expect(dashboard.pending_invitations.count).to eq 0
      end
      dashboard.reload

      expect(dashboard.pending_invitations.count).to eq 0
    end
  end
end
