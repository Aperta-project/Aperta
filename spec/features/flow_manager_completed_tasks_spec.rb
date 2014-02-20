require 'spec_helper'

feature "Flow Manager: completed tasks", js: true do
  let(:admin) do
    FactoryGirl.create :user, :admin
  end
  let(:author) do
    FactoryGirl.create :user, :admin
  end

  let(:paper1) do
    author.papers.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: Journal.create!
  end

  let(:paper2) do
    author.papers.create! short_title: 'bazqux',
      title: 'Baz Qux',
      submitted: true,
      journal: Journal.create!
  end

  def assign_tasks_to_user(paper, user, titles)
    paper.tasks.each { |t| t.update(assignee: user) if titles.include? t.title }
  end

  def complete_tasks(paper, titles)
    paper.tasks.each { |t| t.update(completed: true) if titles.include? t.title }
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  context "with tasks assigned and completed" do
      let(:paper1_task_titles) { ['Assign Editor', 'Assign Admin'] }
      let(:paper2_task_titles) { ['Assign Editor', 'Tech Check'] }
      let(:paper1_completed_task_titles) { ['Assign Editor', 'Assign Admin'] }
      let(:paper2_completed_task_titles) { ['Tech Check'] }

    before do
      assign_tasks_to_user(paper1, admin, paper1_task_titles)
      assign_tasks_to_user(paper2, admin, paper2_task_titles)
      complete_tasks(paper2, paper2_completed_task_titles)
      complete_tasks(paper1, paper1_completed_task_titles)
    end

    scenario "Completed Tasks column" do
      dashboard_page = DashboardPage.visit
      flow_manager_page = dashboard_page.view_flow_manager
      finished_tasks = flow_manager_page.column 'Done'
      papers = finished_tasks.paper_profiles
      expect(papers.map &:title).to match_array [paper1.title, paper1.title, paper2.title]
      paper1_profiles = finished_tasks.paper_profiles_for paper1.title
      paper2_profiles = finished_tasks.paper_profiles_for paper2.title
      paper1_cards = paper1_profiles.flat_map(&:cards)
      paper2_cards = paper2_profiles.flat_map(&:cards)
      expect(paper1_cards.map &:title).to match_array paper1_completed_task_titles
      expect(paper2_cards.map &:title).to match_array paper2_completed_task_titles
      expect(paper1_profiles.count).to eq(paper1_completed_task_titles.count)
      expect(paper2_profiles.count).to eq(paper2_completed_task_titles.count)
      papers.first.view # Verify that we can go to the paper's manage page from its profile.
    end
  end
end
