require 'spec_helper'

feature "Flow Manager: completed tasks", js: true do
  let(:admin) do
    User.create! username: 'zoey',
      first_name: 'Zoey',
      last_name: 'Bob',
      email: 'hi@example.com',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'PLOS',
      admin: true
  end

  let(:author) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      admin: true
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end


  scenario "Completed Tasks column" do
    paper1_task_titles = ['Assign Editor', 'Assign Admin']
    paper2_task_titles = ['Assign Editor', 'Tech Check']
    paper1_completed_task_titles = ['Assign Editor', 'Assign Admin']
    paper2_completed_task_titles = ['Tech Check']
    paper1 = author.papers.create! short_title: 'foobar',
      title: 'Foo bar',
      submitted: true,
      journal: Journal.create!
    paper1.tasks.each { |t| t.update(assignee: admin) if paper1_task_titles.include? t.title }
    paper2 = author.papers.create! short_title: 'bazqux',
      title: 'Baz Qux',
      submitted: true,
      journal: Journal.create!
    paper2.tasks.each { |t| t.update(assignee: admin) if paper2_task_titles.include? t.title }
    paper2.tasks.detect { |t| t.title == 'Tech Check' }.update(completed: true)
    paper1.tasks.detect { |t| t.title == 'Assign Editor' }.update(completed: true)
    paper1.tasks.detect { |t| t.title == 'Assign Admin' }.update(completed: true)

    dashboard_page = DashboardPage.visit
    flow_manager_page = dashboard_page.view_flow_manager
    finished_tasks = flow_manager_page.column 'Done'
    papers = finished_tasks.papers
    expect(papers.map &:title).to match_array [paper1.title, paper1.title, paper2.title]
    paper1_divs = papers.select { |p| p.title == paper1.title }
    paper2_divs = papers.select { |p| p.title == paper2.title }
    paper1_cards = paper1_divs.flat_map(&:cards)
    paper2_cards = paper2_divs.flat_map(&:cards)
    expect(paper1_cards.map &:title).to match_array paper1_completed_task_titles
    expect(paper2_cards.map &:title).to match_array paper2_completed_task_titles
    expect(paper1_divs.count).to eq(paper1_completed_task_titles.count)
    expect(paper2_divs.count).to eq(paper2_completed_task_titles.count)
  end
end
