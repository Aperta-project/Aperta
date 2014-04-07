require 'spec_helper'

feature "Flow Manager", js: true do
  let(:admin) do
    FactoryGirl.create :user, :admin, first_name: "Admin"
  end

  let(:author) do
    FactoryGirl.create :user, :admin, first_name: "Author"
  end

  let(:journal) { Journal.create! }

  let!(:paper1) do
    author.papers.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: journal
  end

  let!(:paper2) do
    author.papers.create! short_title: 'bazqux',
      title: 'Baz Qux',
      submitted: true,
      journal: journal
  end

  def assign_tasks_to_user(paper, user, titles)
    paper.tasks.each { |t| t.update(assignee: user) if titles.include? t.title }
  end

  def complete_tasks(paper, titles)
    paper.tasks.each { |t| t.update(completed: true) if titles.include? t.title }
  end

  before do
    JournalRole.create! user: admin, journal: journal, admin: true
    @old_size = page.driver.browser.manage.window.size
    page.driver.browser.manage.window.resize_to(1250,550)
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  after do
    page.driver.browser.manage.window.size = @old_size
  end

  scenario "admin removes a column from their flow manager" do
    dashboard_page = DashboardPage.visit
    flow_manager_page = dashboard_page.view_flow_manager
    up_for_grabs = flow_manager_page.column 'Up for grabs'
    up_for_grabs.remove

    expect(flow_manager_page).not_to have_column 'Up for grabs'
    flow_manager_page.reload
    expect(flow_manager_page).not_to have_column 'Up for grabs'
  end

  scenario "admin adds a column to their flow manager" do
    dashboard_page = DashboardPage.visit
    flow_manager_page = dashboard_page.view_flow_manager

    expect { flow_manager_page.add_column "Up for grabs" }.to change {
      flow_manager_page.columns("Up for grabs").count
    }.by(1)

    flow_manager_page.reload

    expect(flow_manager_page.columns("Up for grabs").count).to eq(2)
  end

  scenario "papers without assigned admins" do
    paper1.tasks.detect { |t| t.title == 'Assign Admin' }.update! assignee: admin

    dashboard_page = DashboardPage.visit
    flow_manager_page = dashboard_page.view_flow_manager
    up_for_grabs = flow_manager_page.column 'Up for grabs'
    papers = up_for_grabs.paper_profiles
    expect(papers.length).to eq 1
    paper = papers.first
    expect(paper.title).to eq paper2.title
    cards = paper.cards
    expect(cards.length).to eq 1
    expect(cards.first.title).to eq 'Assign Admin'
  end

  context "an admin with papers assigned to them" do
    before do
      assign_tasks_to_user(paper1, admin, ['Assign Admin'])
      assign_tasks_to_user(paper2, admin, ['Assign Admin'])
    end

    scenario "Your Papers" do
      dashboard_page = DashboardPage.visit
      flow_manager_page = dashboard_page.view_flow_manager

      my_tasks = flow_manager_page.column 'My papers'
      papers = my_tasks.paper_profiles
      expect(papers.map &:title).to match_array [paper1.title, paper2.title]
      papers.first.view # Verify that we can go to the paper's manage page from its profile.
    end
  end

  context "empty tasks" do
    scenario "there are no tasks" do
      dashboard_page = DashboardPage.visit
      flow_manager_page = dashboard_page.view_flow_manager

      my_tasks = flow_manager_page.column 'My papers'
      expect(my_tasks.has_empty_text?).to eq(true)
    end
  end

  context "with tasks assigned and completed" do
    let(:paper1_task_titles) { ['Assign Editor', 'Tech Check', 'Assign Reviewers'] }
    let(:paper2_task_titles) { ['Assign Editor', 'Assign Reviewers', 'Upload Figures'] }
    let(:paper1_completed_task_titles) { ['Assign Editor', 'Tech Check'] }
    let(:paper2_completed_task_titles) { ['Upload Figures'] }

    before do
      assign_tasks_to_user(paper1, admin, paper1_task_titles)
      assign_tasks_to_user(paper2, admin, paper2_task_titles)
      complete_tasks(paper2, paper2_completed_task_titles)
      complete_tasks(paper1, paper1_completed_task_titles)
    end

    def my_task_expectations(flow_manager_page)
      my_tasks = flow_manager_page.column 'My tasks'
      papers = my_tasks.paper_profiles
      expect(papers.map &:title).to match_array [paper1.title, paper2.title]
      paper1_cards = papers.detect { |p| p.title == paper1.title }.cards
      paper2_cards = papers.detect { |p| p.title == paper2.title }.cards
      expect(paper1_cards.map &:title).to match_array (paper1_task_titles - paper1_completed_task_titles)
      expect(paper2_cards.map &:title).to match_array (paper2_task_titles - paper2_completed_task_titles)
      papers #return papers for later use
    end

    def completed_task_expectations(flow_manager_page)
      finished_tasks = flow_manager_page.column 'Done'
      papers = finished_tasks.paper_profiles
      expect(papers.map &:title).to match_array [paper1.title, paper2.title]
      paper1_profiles = finished_tasks.paper_profiles_for paper1.title
      paper2_profiles = finished_tasks.paper_profiles_for paper2.title
      paper1_cards = paper1_profiles.flat_map(&:cards)
      paper2_cards = paper2_profiles.flat_map(&:cards)
      expect(paper1_cards.map &:title).to match_array paper1_completed_task_titles
      expect(paper2_cards.map &:title).to match_array paper2_completed_task_titles
      papers #return papers for later use
    end

    scenario "Viewing the flow manager" do
      dashboard_page = DashboardPage.visit
      flow_manager_page = dashboard_page.view_flow_manager
      my_task_expectations flow_manager_page
      completed_papers = completed_task_expectations flow_manager_page
      completed_papers.first.view # Verify that we can go to the paper's manage page from its profile.
    end

  end
end
